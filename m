Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E1BF46B002D
	for <linux-mm@kvack.org>; Sun, 27 Nov 2011 19:37:21 -0500 (EST)
Received: by lamb11 with SMTP id b11so575021lam.14
        for <linux-mm@kvack.org>; Sun, 27 Nov 2011 16:37:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1322062951-1756-2-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
	<1322062951-1756-2-git-send-email-hannes@cmpxchg.org>
Date: Mon, 28 Nov 2011 06:07:17 +0530
Message-ID: <CAKTCnzmfk5O24R2Lh08e-WgA75TtTaO11vZjJOnPXxHhThX-XA@mail.gmail.com>
Subject: Re: [patch 1/8] mm: oom_kill: remove memcg argument from oom_kill_task()
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 23, 2011 at 9:12 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
>
> From: Johannes Weiner <jweiner@redhat.com>
>
> The memcg argument of oom_kill_task() hasn't been used since 341aea2
> 'oom-kill: remove boost_dying_task_prio()'. =A0Kill it.
>
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> ---
> =A0mm/oom_kill.c | =A0 =A04 ++--
> =A01 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 471dedb..fd9e303 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -423,7 +423,7 @@ static void dump_header(struct task_struct *p, gfp_t =
gfp_mask, int order,
> =A0}
>
> =A0#define K(x) ((x) << (PAGE_SHIFT-10))
> -static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> +static int oom_kill_task(struct task_struct *p)
> =A0{
> =A0 =A0 =A0 =A0struct task_struct *q;
> =A0 =A0 =A0 =A0struct mm_struct *mm;
> @@ -522,7 +522,7 @@ static int oom_kill_process(struct task_struct *p, gf=
p_t gfp_mask, int order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0} while_each_thread(p, t);
>
> - =A0 =A0 =A0 return oom_kill_task(victim, mem);
> + =A0 =A0 =A0 return oom_kill_task(victim);
> =A0}
>

Looks good!

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
