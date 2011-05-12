Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1B154900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:53:44 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p4CIreYc015955
	for <linux-mm@kvack.org>; Thu, 12 May 2011 11:53:40 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by kpbe17.cbf.corp.google.com with ESMTP id p4CIrcZ6014783
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 11:53:38 -0700
Received: by qyk10 with SMTP id 10so1112689qyk.4
        for <linux-mm@kvack.org>; Thu, 12 May 2011 11:53:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
Date: Thu, 12 May 2011 11:53:37 -0700
Message-ID: <BANLkTikHhK8S-fMpe=KOYCF0kmXotHKCOQ@mail.gmail.com>
Subject: Re: [rfc patch 0/6] mm: memcg naturalization
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefdafd6ae304a318b4e6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--0016e64aefdafd6ae304a318b4e6
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hi!
>
> Here is a patch series that is a result of the memcg discussions on
> LSF (memcg-aware global reclaim, global lru removal, struct
> page_cgroup reduction, soft limit implementation) and the recent
> feature discussions on linux-mm.
>
> The long-term idea is to have memcgs no longer bolted to the side of
> the mm code, but integrate it as much as possible such that there is a
> native understanding of containers, and that the traditional !memcg
> setup is just a singular group.  This series is an approach in that
> direction.
>
> It is a rather early snapshot, WIP, barely tested etc., but I wanted
> to get your opinions before further pursuing it.  It is also part of
> my counter-argument to the proposals of adding memcg-reclaim-related
> user interfaces at this point in time, so I wanted to push this out
> the door before things are merged into .40.
>

The memcg-reclaim-related user interface I assume was the watermark
configurable tunable
we were talking about in the per-memcg background reclaim patch. I think we
got some agreement
to remove the watermark tunable at the first step. But the newly added
memory.soft_limit_async_reclaim
as you proposed seems to be a usable interface.


>
> The patches are quite big, I am still looking for things to factor and
> split out, sorry for this.  Documentation is on its way as well ;)
>

This is a quite bit patchset includes different part. We might want to split
it into steps. I will read them through
now.

--Ying

>
> #1 and #2 are boring preparational work.  #3 makes traditional reclaim
> in vmscan.c memcg-aware, which is a prerequisite for both removal of
> the global lru in #5 and the way I reimplemented soft limit reclaim in
> #6.
>
> The diffstat so far looks like this:
>
>  include/linux/memcontrol.h  |   84 +++--
>  include/linux/mm_inline.h   |   15 +-
>  include/linux/mmzone.h      |   10 +-
>  include/linux/page_cgroup.h |   35 --
>  include/linux/swap.h        |    4 -
>  mm/memcontrol.c             |  860
> +++++++++++++------------------------------
>  mm/page_alloc.c             |    2 +-
>  mm/page_cgroup.c            |   39 +--
>  mm/swap.c                   |   20 +-
>  mm/vmscan.c                 |  273 +++++++--------
>  10 files changed, 452 insertions(+), 890 deletions(-)
>
> It is based on .39-rc7 because of the memcg churn in -mm, but I'll
> rebase it in the near future.
>
> Discuss!
>
>        Hannes
>

--0016e64aefdafd6ae304a318b4e6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 12, 2011 at 7:53 AM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Hi!<br>
<br>
Here is a patch series that is a result of the memcg discussions on<br>
LSF (memcg-aware global reclaim, global lru removal, struct<br>
page_cgroup reduction, soft limit implementation) and the recent<br>
feature discussions on linux-mm.<br>
<br>
The long-term idea is to have memcgs no longer bolted to the side of<br>
the mm code, but integrate it as much as possible such that there is a<br>
native understanding of containers, and that the traditional !memcg<br>
setup is just a singular group. =A0This series is an approach in that<br>
direction.<br>
<br>
It is a rather early snapshot, WIP, barely tested etc., but I wanted<br>
to get your opinions before further pursuing it. =A0It is also part of<br>
my counter-argument to the proposals of adding memcg-reclaim-related<br>
user interfaces at this point in time, so I wanted to push this out<br>
the door before things are merged into .40.<br></blockquote><div><br></div>=
<div>The memcg-reclaim-related user interface I assume was the watermark co=
nfigurable tunable</div><div>we were talking about in the per-memcg backgro=
und reclaim patch. I think we got some agreement</div>
<div>to remove the watermark tunable at the first step. But the newly added=
 memory.soft_limit_async_reclaim</div><div>as you proposed seems to be a us=
able interface.</div><div>=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

<br>
The patches are quite big, I am still looking for things to factor and<br>
split out, sorry for this. =A0Documentation is on its way as well ;)<br></b=
lockquote><div><br></div><div>This is a quite bit patchset includes differe=
nt part. We might want to split it into steps. I will read them through</di=
v>
<div>now.</div><div><br></div><div>--Ying=A0</div><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex;">
<br>
#1 and #2 are boring preparational work. =A0#3 makes traditional reclaim<br=
>
in vmscan.c memcg-aware, which is a prerequisite for both removal of<br>
the global lru in #5 and the way I reimplemented soft limit reclaim in<br>
#6.<br>
<br>
The diffstat so far looks like this:<br>
<br>
=A0include/linux/memcontrol.h =A0| =A0 84 +++--<br>
=A0include/linux/mm_inline.h =A0 | =A0 15 +-<br>
=A0include/linux/mmzone.h =A0 =A0 =A0| =A0 10 +-<br>
=A0include/linux/page_cgroup.h | =A0 35 --<br>
=A0include/linux/swap.h =A0 =A0 =A0 =A0| =A0 =A04 -<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0860 +++++++++++++----------=
--------------------<br>
=A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-<br>
=A0mm/page_cgroup.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 39 +--<br>
=A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 20 +-<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0273 +++++++--------<br>
=A010 files changed, 452 insertions(+), 890 deletions(-)<br>
<br>
It is based on .39-rc7 because of the memcg churn in -mm, but I&#39;ll<br>
rebase it in the near future.<br>
<br>
Discuss!<br>
<br>
 =A0 =A0 =A0 =A0Hannes<br>
</blockquote></div><br>

--0016e64aefdafd6ae304a318b4e6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
