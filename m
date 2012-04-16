Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C67886B0103
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 13:33:25 -0400 (EDT)
Received: by lbbgp10 with SMTP id gp10so2065953lbb.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 10:33:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBDDW7DBtpiOERXXPzh40SHkhwQ5K9OnM6HiQXRR2Cm3hA@mail.gmail.com>
References: <1334181594-26671-1-git-send-email-yinghan@google.com>
	<CAJd=RBDDW7DBtpiOERXXPzh40SHkhwQ5K9OnM6HiQXRR2Cm3hA@mail.gmail.com>
Date: Mon, 16 Apr 2012 10:33:23 -0700
Message-ID: <CALWz4ix+AbeGwWmzbb1Q+f2G-h0=wXj+m7fJuXDy+ou-GXMGmw@mail.gmail.com>
Subject: Re: [PATCH V2 1/5] memcg: revert current soft limit reclaim implementation
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Sat, Apr 14, 2012 at 5:41 AM, Hillf Danton <dhillf@gmail.com> wrote:
> On Thu, Apr 12, 2012 at 5:59 AM, Ying Han <yinghan@google.com> wrote:
>> This patch reverts all the existing softlimit reclaim implementations.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0include/linux/memcontrol.h | =A0 11 --
>> =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A04 -
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0387 ---------------------=
-----------------------
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 67 --------
>> =A04 files changed, 0 insertions(+), 469 deletions(-)
>>
> [...]
>
>> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int orde=
r,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 gfp_t gfp_mask,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 unsigned long *total_scanned)
>> -{
>> - =A0 =A0 =A0 unsigned long nr_reclaimed =3D 0;
>> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz, *next_mz =3D NULL;
>> - =A0 =A0 =A0 unsigned long reclaimed;
>> - =A0 =A0 =A0 int loop =3D 0;
>> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *mctz;
>> - =A0 =A0 =A0 unsigned long long excess;
>> - =A0 =A0 =A0 unsigned long nr_scanned;
>> -
>> - =A0 =A0 =A0 if (order > 0)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> -
> Not related to this patch, what is the functionality to check order?

The new implementation doesn't need to check order like before.

The existing soft_limit reclaim skips high order allocation since it's
been best effort before the actual reclaim on global lru. Now the
global lru is gone and all reclaims happens on per-memcg level. The
high order page allocation is being taken care of automatically like
other part of reclaim logic.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
