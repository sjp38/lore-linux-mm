Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 17D8E6B0083
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 08:41:58 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so3706678vbb.14
        for <linux-mm@kvack.org>; Sat, 14 Apr 2012 05:41:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334181594-26671-1-git-send-email-yinghan@google.com>
References: <1334181594-26671-1-git-send-email-yinghan@google.com>
Date: Sat, 14 Apr 2012 20:41:57 +0800
Message-ID: <CAJd=RBDDW7DBtpiOERXXPzh40SHkhwQ5K9OnM6HiQXRR2Cm3hA@mail.gmail.com>
Subject: Re: [PATCH V2 1/5] memcg: revert current soft limit reclaim implementation
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Thu, Apr 12, 2012 at 5:59 AM, Ying Han <yinghan@google.com> wrote:
> This patch reverts all the existing softlimit reclaim implementations.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =C2=A0include/linux/memcontrol.h | =C2=A0 11 --
> =C2=A0include/linux/swap.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A04 -
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A038=
7 --------------------------------------------
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
| =C2=A0 67 --------
> =C2=A04 files changed, 0 insertions(+), 469 deletions(-)
>
[...]

> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order=
,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 gfp_t gfp_mask,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 unsigned long *total_scanned)
> -{
> - =C2=A0 =C2=A0 =C2=A0 unsigned long nr_reclaimed =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_per_zone *mz, *next_mz =3D NULL;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long reclaimed;
> - =C2=A0 =C2=A0 =C2=A0 int loop =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_tree_per_zone *mctz;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long long excess;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long nr_scanned;
> -
> - =C2=A0 =C2=A0 =C2=A0 if (order > 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> -
Not related to this patch, what is the functionality to check order?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
