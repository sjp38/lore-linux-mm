Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5068D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 20:56:30 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p4I0uO6T009338
	for <linux-mm@kvack.org>; Tue, 17 May 2011 17:56:24 -0700
Received: from qwe5 (qwe5.prod.google.com [10.241.194.5])
	by wpaz13.hot.corp.google.com with ESMTP id p4I0uN6h029612
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 May 2011 17:56:23 -0700
Received: by qwe5 with SMTP id 5so652909qwe.37
        for <linux-mm@kvack.org>; Tue, 17 May 2011 17:56:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110518090047.0b46a60d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305583230-2111-1-git-send-email-yinghan@google.com>
	<20110516231512.GW16531@cmpxchg.org>
	<BANLkTinohFTQRTViyU5NQ6EGi95xieXwOA@mail.gmail.com>
	<20110516171820.124a8fbc.akpm@linux-foundation.org>
	<20110518084919.988d3d41.kamezawa.hiroyu@jp.fujitsu.com>
	<20110518090047.0b46a60d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 17 May 2011 17:56:23 -0700
Message-ID: <BANLkTin30x-AJ8aA5ARdE6sUtEO4QELKYg@mail.gmail.com>
Subject: Re: [PATCH] memcg: fix typo in the soft_limit stats.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5c840ebf04a3825bb7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5c840ebf04a3825bb7
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 17, 2011 at 5:00 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 18 May 2011 08:49:19 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> > On Mon, 16 May 2011 17:18:20 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > > On Mon, 16 May 2011 17:05:02 -0700
> > > Ying Han <yinghan@google.com> wrote:
> > >
> > > > On Mon, May 16, 2011 at 4:15 PM, Johannes Weiner <hannes@cmpxchg.org>
> wrote:
> > > >
> > > > > On Mon, May 16, 2011 at 03:00:30PM -0700, Ying Han wrote:
> > > > > > This fixes the typo in the memory.stat including the following
> two
> > > > > > stats:
> > > > > >
> > > > > > $ cat /dev/cgroup/memory/A/memory.stat
> > > > > > total_soft_steal 0
> > > > > > total_soft_scan 0
> > > > > >
> > > > > > And change it to:
> > > > > >
> > > > > > $ cat /dev/cgroup/memory/A/memory.stat
> > > > > > total_soft_kswapd_steal 0
> > > > > > total_soft_kswapd_scan 0
> > > > > >
> > > > > > Signed-off-by: Ying Han <yinghan@google.com>
> > > > >
> > > > > I am currently proposing and working on a scheme that makes the
> soft
> > > > > limit not only a factor for global memory pressure, but for
> > > > > hierarchical reclaim in general, to prefer child memcgs during
> reclaim
> > > > > that are in excess of their soft limit.
> > > > >
> > > > > Because this means prioritizing memcgs over one another, rather
> than
> > > > > having explicit soft limit reclaim runs, there is no natural
> counter
> > > > > for pages reclaimed due to the soft limit anymore.
> > > > >
> > > > > Thus, for the patch that introduces this counter:
> > > > >
> > > > > Nacked-by: Johannes Weiner <hannes@cmpxchg.org>
> > > > >
> > > >
> > > > This patch is fixing a typo of the stats being integrated into mmotm.
> Does
> > > > it make sense to fix the
> > > > existing stats first while we are discussing other approaches?
> > > >
> > >
> > > It would be quite bad to add new userspace-visible stats and to then
> > > take them away again.
> > >
> > yes.
> >
> > > But given that memcg-add-stats-to-monitor-soft_limit-reclaim.patch is
> > > queued for 2.6.39-rc1, we could proceed with that plan and then make
> > > sure that Johannes's changes are merged either prior to 2.6.40 or
> > > they are never merged at all.
> > >
> > > Or we could just leave out the stats until we're sure.  Not having them
> > > for a while is not as bad as adding them and then removing them.
> > >
> >
> > I agree. I'm okay with removing them for a while. Johannes and Ying,
> could you
> > make a concensus ? IMHO, Johannes' work for making soft-limit
> co-operative with
> > hirerachical reclaim makes sense and agree to leave counter name as it
> is.
> >
>
> After reading threads, an another idea comes. Johannes' soft_limit just
> works
> when the hierarchy hit limit. I think pages are not reclaimed by
> soft_limit...
> it just reclaimed by the limit because of hierarchy. Right ?
>

My understanding of Johannes's proposal is to do soft_limit reclaim from any
memory pressure could happen on the memcg ( global reclaim,  parent hit the
hard_limit, per-memcg bg reclaim ).

If that is something we agree to proceed, the existing stats only covers
partially what we would like to count. Now it only count the soft_limit
reclaim from the global memory pressure.

Hmm, I'm not sure using counter of softlimit or (new) counter of
> reclaimed-by-parent
> for that purpose.
>
> But I think this change of stat name is not necessary, anyway.
>

 I am ok to revert this stat now since we are having the whole discussion on
the soft_limit reclaim implementation.

--Ying

>
> Thanks,
> -Kame
>
>
>
>

--0016360e3f5c840ebf04a3825bb7
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, May 17, 2011 at 5:00 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Wed, 18 May 2011 08:49:19 +0900<br>
KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kam=
ezawa.hiroyu@jp.fujitsu.com</a>&gt; wrote:<br>
<br>
&gt; On Mon, 16 May 2011 17:18:20 -0700<br>
&gt; Andrew Morton &lt;<a href=3D"mailto:akpm@linux-foundation.org">akpm@li=
nux-foundation.org</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Mon, 16 May 2011 17:05:02 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; On Mon, May 16, 2011 at 4:15 PM, Johannes Weiner &lt;<a href=
=3D"mailto:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; On Mon, May 16, 2011 at 03:00:30PM -0700, Ying Han wrot=
e:<br>
&gt; &gt; &gt; &gt; &gt; This fixes the typo in the memory.stat including t=
he following two<br>
&gt; &gt; &gt; &gt; &gt; stats:<br>
&gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.stat<br>
&gt; &gt; &gt; &gt; &gt; total_soft_steal 0<br>
&gt; &gt; &gt; &gt; &gt; total_soft_scan 0<br>
&gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; And change it to:<br>
&gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.stat<br>
&gt; &gt; &gt; &gt; &gt; total_soft_kswapd_steal 0<br>
&gt; &gt; &gt; &gt; &gt; total_soft_kswapd_scan 0<br>
&gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:ying=
han@google.com">yinghan@google.com</a>&gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; I am currently proposing and working on a scheme that m=
akes the soft<br>
&gt; &gt; &gt; &gt; limit not only a factor for global memory pressure, but=
 for<br>
&gt; &gt; &gt; &gt; hierarchical reclaim in general, to prefer child memcgs=
 during reclaim<br>
&gt; &gt; &gt; &gt; that are in excess of their soft limit.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Because this means prioritizing memcgs over one another=
, rather than<br>
&gt; &gt; &gt; &gt; having explicit soft limit reclaim runs, there is no na=
tural counter<br>
&gt; &gt; &gt; &gt; for pages reclaimed due to the soft limit anymore.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Thus, for the patch that introduces this counter:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Nacked-by: Johannes Weiner &lt;<a href=3D"mailto:hannes=
@cmpxchg.org">hannes@cmpxchg.org</a>&gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; This patch is fixing a typo of the stats being integrated in=
to mmotm. Does<br>
&gt; &gt; &gt; it make sense to fix the<br>
&gt; &gt; &gt; existing stats first while we are discussing other approache=
s?<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; It would be quite bad to add new userspace-visible stats and to t=
hen<br>
&gt; &gt; take them away again.<br>
&gt; &gt;<br>
&gt; yes.<br>
&gt;<br>
&gt; &gt; But given that memcg-add-stats-to-monitor-soft_limit-reclaim.patc=
h is<br>
&gt; &gt; queued for 2.6.39-rc1, we could proceed with that plan and then m=
ake<br>
&gt; &gt; sure that Johannes&#39;s changes are merged either prior to 2.6.4=
0 or<br>
&gt; &gt; they are never merged at all.<br>
&gt; &gt;<br>
&gt; &gt; Or we could just leave out the stats until we&#39;re sure. =A0Not=
 having them<br>
&gt; &gt; for a while is not as bad as adding them and then removing them.<=
br>
&gt; &gt;<br>
&gt;<br>
&gt; I agree. I&#39;m okay with removing them for a while. Johannes and Yin=
g, could you<br>
&gt; make a concensus ? IMHO, Johannes&#39; work for making soft-limit co-o=
perative with<br>
&gt; hirerachical reclaim makes sense and agree to leave counter name as it=
 is.<br>
&gt;<br>
<br>
</div></div>After reading threads, an another idea comes. Johannes&#39; sof=
t_limit just works<br>
when the hierarchy hit limit. I think pages are not reclaimed by soft_limit=
...<br>
it just reclaimed by the limit because of hierarchy. Right ?<br></blockquot=
e><div><br></div><div>My understanding of <span class=3D"Apple-style-span" =
style=3D"border-collapse: collapse; font-family: arial, sans-serif; font-si=
ze: 13px; ">Johannes&#39;s proposal is to do soft_limit reclaim from any me=
mory pressure could happen on the memcg ( global reclaim, =A0parent hit the=
 hard_limit, per-memcg bg reclaim ).</span></div>
<div><span class=3D"Apple-style-span" style=3D"border-collapse: collapse; f=
ont-family: arial, sans-serif; font-size: 13px; "><br></span></div><div><sp=
an class=3D"Apple-style-span" style=3D"border-collapse: collapse; font-fami=
ly: arial, sans-serif; font-size: 13px; ">If that is something we agree to =
proceed, the existing stats only covers partially what we would like to cou=
nt. </span><span class=3D"Apple-style-span" style=3D"border-collapse: colla=
pse; font-family: arial, sans-serif; font-size: 13px; ">Now it only count t=
he soft_limit reclaim from the global memory pressure.</span></div>
<div><span class=3D"Apple-style-span" style=3D"border-collapse: collapse; f=
ont-family: arial, sans-serif; font-size: 13px; "><br></span></div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc s=
olid;padding-left:1ex;">

Hmm, I&#39;m not sure using counter of softlimit or (new) counter of reclai=
med-by-parent<br>
for that purpose.<br>
<br>
But I think this change of stat name is not necessary, anyway.<br></blockqu=
ote><div><br></div><div>=A0I am ok to revert this stat now since we are hav=
ing the whole discussion on the soft_limit reclaim implementation.=A0</div>
<div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
Thanks,<br>
-Kame<br>
<br>
<br>
<br>
</blockquote></div><br>

--0016360e3f5c840ebf04a3825bb7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
