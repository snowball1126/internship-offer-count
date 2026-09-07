-- 求职投递台账 V1.4：Supabase 云端数据表与按账号隔离权限
-- 只需要在 Supabase SQL Editor 中执行一次。

create extension if not exists pgcrypto;

create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  company text not null,
  title text not null,
  application_method text not null check (application_method in ('官网', '公众号', '线下', '其他')),
  status text not null check (status in ('已投递', '笔试完', '一面面试完', '二面面试完', '三面面试完', '等待Offer', '已结束')),
  website text not null default '',
  website_source text not null default '',
  applied_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists applications_user_id_idx on public.applications(user_id);
create index if not exists applications_applied_at_idx on public.applications(user_id, applied_at desc);

alter table public.applications enable row level security;

revoke all on public.applications from anon;
grant select, insert, update, delete on public.applications to authenticated;

drop policy if exists "Users can read own applications" on public.applications;
drop policy if exists "Users can insert own applications" on public.applications;
drop policy if exists "Users can update own applications" on public.applications;
drop policy if exists "Users can delete own applications" on public.applications;

create policy "Users can read own applications"
  on public.applications for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can insert own applications"
  on public.applications for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update own applications"
  on public.applications for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete own applications"
  on public.applications for delete
  to authenticated
  using ((select auth.uid()) = user_id);
