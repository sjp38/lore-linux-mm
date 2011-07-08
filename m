Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C8BC99000C2
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 13:03:15 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p68H3ClF009103
	for <linux-mm@kvack.org>; Fri, 8 Jul 2011 10:03:12 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by hpaq1.eem.corp.google.com with ESMTP id p68Gqlc3005553
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 8 Jul 2011 10:03:11 -0700
Received: by qwf7 with SMTP id 7so1332322qwf.24
        for <linux-mm@kvack.org>; Fri, 08 Jul 2011 10:03:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308696090-31569-1-git-send-email-yinghan@google.com>
References: <1308696090-31569-1-git-send-email-yinghan@google.com>
Date: Fri, 8 Jul 2011 10:03:05 -0700
Message-ID: <CALWz4iz=C=UfNu7uJvFnnj9LBVZMyZXxO0hkgBr_cA27dXeHMA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] softlimit reclaim and zone->lru_lock rework
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016363b9e30a0b31f04a791cecf
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

--0016363b9e30a0b31f04a791cecf
Content-Type: text/plain; charset=ISO-8859-1

update Balbir's email in the cc list.

--Ying

On Tue, Jun 21, 2011 at 3:41 PM, Ying Han <yinghan@google.com> wrote:

> The patchset is based on mmotm-2011-05-12-15-52 plus the following patches.
>
> [BUGFIX][PATCH 5/5] memcg: fix percpu cached charge draining frequency
> [patch 1/8] memcg: remove unused retry signal from reclaim
> [patch 2/8] mm: memcg-aware global reclaim
> [patch 3/8] memcg: reclaim statistics
> [patch 6/8] vmscan: change zone_nr_lru_pages to take memcg instead of scan
> control
> [patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
> [patch 8/8] mm: make per-memcg lru lists exclusive
>
> This patchset comes only after Johannes "memcg naturalization" effort. I
> don't
> expect this to be merged soon. The reason for me to post it here for
> syncing up
> with ppl with the current status of the effort. And also comments and code
> reviews
> are welcomed.
>
> This patchset includes:
> 1. rework softlimit reclaim on priority based. this depends on the
> "memcg-aware
> global reclaim" patch.
> 2. break the zone->lru_lock for memcg reclaim. this depends on the
> "per-memcg
> lru lists exclusive" patch.
>
> I would definitely make them as two seperate patches later. For now, this
> is
> only to sync-up with folks on the status of the effort.
>
> Ying Han (5):
>  Revert soft_limit reclaim changes under global pressure.
>  Revert soft limit reclaim implementation in memcg.
>  rework softlimit reclaim.
>  memcg: break the zone->lru_lock in memcg-aware reclaim
>  Move the lru_lock into the lruvec struct.
>
>  include/linux/memcontrol.h |   35 ++-
>  include/linux/mm_types.h   |    2 +-
>  include/linux/mmzone.h     |    8 +-
>  include/linux/swap.h       |    5 -
>  mm/compaction.c            |   41 +++--
>  mm/huge_memory.c           |    5 +-
>  mm/memcontrol.c            |  502
> ++++++--------------------------------------
>  mm/page_alloc.c            |    2 +-
>  mm/rmap.c                  |    2 +-
>  mm/swap.c                  |   71 ++++---
>  mm/vmscan.c                |  186 ++++++++---------
>  11 files changed, 246 insertions(+), 613 deletions(-)
>
> --
> 1.7.3.1
>
>

--0016363b9e30a0b31f04a791cecf
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

update Balbir&#39;s email in the cc list.<div><br></div><div>--Ying<br><br>=
<div class=3D"gmail_quote">On Tue, Jun 21, 2011 at 3:41 PM, Ying Han <span =
dir=3D"ltr">&lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a=
>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">The patchset is based on mmotm-2011-05-12-1=
5-52 plus the following patches.<br>
<br>
[BUGFIX][PATCH 5/5] memcg: fix percpu cached charge draining frequency<br>
[patch 1/8] memcg: remove unused retry signal from reclaim<br>
[patch 2/8] mm: memcg-aware global reclaim<br>
[patch 3/8] memcg: reclaim statistics<br>
[patch 6/8] vmscan: change zone_nr_lru_pages to take memcg instead of scan =
control<br>
[patch 7/8] vmscan: memcg-aware unevictable page rescue scanner<br>
[patch 8/8] mm: make per-memcg lru lists exclusive<br>
<br>
This patchset comes only after Johannes &quot;memcg naturalization&quot; ef=
fort. I don&#39;t<br>
expect this to be merged soon. The reason for me to post it here for syncin=
g up<br>
with ppl with the current status of the effort. And also comments and code =
reviews<br>
are welcomed.<br>
<br>
This patchset includes:<br>
1. rework softlimit reclaim on priority based. this depends on the &quot;me=
mcg-aware<br>
global reclaim&quot; patch.<br>
2. break the zone-&gt;lru_lock for memcg reclaim. this depends on the &quot=
;per-memcg<br>
lru lists exclusive&quot; patch.<br>
<br>
I would definitely make them as two seperate patches later. For now, this i=
s<br>
only to sync-up with folks on the status of the effort.<br>
<br>
Ying Han (5):<br>
 =A0Revert soft_limit reclaim changes under global pressure.<br>
 =A0Revert soft limit reclaim implementation in memcg.<br>
 =A0rework softlimit reclaim.<br>
 =A0memcg: break the zone-&gt;lru_lock in memcg-aware reclaim<br>
 =A0Move the lru_lock into the lruvec struct.<br>
<br>
=A0include/linux/memcontrol.h | =A0 35 ++-<br>
=A0include/linux/mm_types.h =A0 | =A0 =A02 +-<br>
=A0include/linux/mmzone.h =A0 =A0 | =A0 =A08 +-<br>
=A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A05 -<br>
=A0mm/compaction.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 41 +++--<br>
=A0mm/huge_memory.c =A0 =A0 =A0 =A0 =A0 | =A0 =A05 +-<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0502 ++++++------------------=
--------------------<br>
=A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-<br>
=A0mm/rmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-<br>
=A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 71 ++++---<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0186 ++++++++---------<br=
>
=A011 files changed, 246 insertions(+), 613 deletions(-)<br>
<font color=3D"#888888"><br>
--<br>
1.7.3.1<br>
<br>
</font></blockquote></div><br></div>

--0016363b9e30a0b31f04a791cecf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
