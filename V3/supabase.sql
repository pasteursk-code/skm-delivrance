-- SKM DÉLIVRANCE V3 - schéma minimal sécurisé
-- À exécuter dans Supabase > SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.admin_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Révérend Serge Kassi',
  created_at timestamptz not null default now()
);

create table if not exists public.dossiers (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  full_name text not null,
  phone text,
  email text,
  city text,
  age_range text,
  church text,
  consent boolean not null default false,
  answers jsonb not null default '{}'::jsonb,
  categories jsonb not null default '{}'::jsonb,
  pathway jsonb not null default '[]'::jsonb,
  pathway_completed integer not null default 0,
  recommended_book text,
  summary text,
  appointment_requested boolean not null default false,
  status text not null default 'Nouveau',
  private_notes text
);

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  dossier_id uuid not null references public.dossiers(id) on delete cascade,
  created_at timestamptz not null default now(),
  preferred_date date,
  preferred_time text,
  modality text,
  message text,
  status text not null default 'Demandé'
);

alter table public.admin_profiles enable row level security;
alter table public.dossiers enable row level security;
alter table public.appointments enable row level security;

create or replace function public.is_skm_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(
    select 1 from public.admin_profiles ap where ap.user_id = auth.uid()
  );
$$;

-- Une personne anonyme peut uniquement déposer sa fiche complète.
drop policy if exists "anon_insert_dossiers" on public.dossiers;
create policy "anon_insert_dossiers"
on public.dossiers for insert
to anon
with check (consent = true);

-- Aucun dossier ne peut être lu anonymement.
drop policy if exists "admin_select_dossiers" on public.dossiers;
create policy "admin_select_dossiers"
on public.dossiers for select
to authenticated
using (public.is_skm_admin());

-- Seul l'administrateur peut modifier l'état, les notes, etc.
drop policy if exists "admin_update_dossiers" on public.dossiers;
create policy "admin_update_dossiers"
on public.dossiers for update
to authenticated
using (public.is_skm_admin())
with check (public.is_skm_admin());

-- Rendez-vous : insertion anonyme liée à un dossier existant.
drop policy if exists "anon_insert_appointments" on public.appointments;
create policy "anon_insert_appointments"
on public.appointments for insert
to anon
with check (true);

-- Lecture et modification réservées à l'administrateur.
drop policy if exists "admin_select_appointments" on public.appointments;
create policy "admin_select_appointments"
on public.appointments for select
to authenticated
using (public.is_skm_admin());

drop policy if exists "admin_update_appointments" on public.appointments;
create policy "admin_update_appointments"
on public.appointments for update
to authenticated
using (public.is_skm_admin())
with check (public.is_skm_admin());

-- Admin profiles : seul l'admin déjà enregistré peut lire sa propre ligne.
drop policy if exists "admin_read_self" on public.admin_profiles;
create policy "admin_read_self"
on public.admin_profiles for select
to authenticated
using (user_id = auth.uid());

-- IMPORTANT : après la première connexion dans admin.html,
-- copiez l'UUID de votre utilisateur depuis Supabase > Authentication > Users
-- puis exécutez UNE FOIS dans le SQL Editor :
-- insert into public.admin_profiles(user_id, display_name)
-- values ('VOTRE-UUID-ICI', 'Révérend Serge Kassi');
