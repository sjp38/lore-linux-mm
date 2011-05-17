Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A72F96B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 20:53:10 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p4H0r83C001704
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:53:08 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by kpbe14.cbf.corp.google.com with ESMTP id p4H0r465017070
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:53:07 -0700
Received: by qwb8 with SMTP id 8so13461qwb.11
        for <linux-mm@kvack.org>; Mon, 16 May 2011 17:53:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110513072043.GE18610@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<BANLkTikHhK8S-fMpe=KOYCF0kmXotHKCOQ@mail.gmail.com>
	<20110513072043.GE18610@cmpxchg.org>
Date: Mon, 16 May 2011 17:53:04 -0700
Message-ID: <BANLkTiky6=xwqb_ML1wg=8Gg=BO0nmeUog@mail.gmail.com>
Subject: Re: [rfc patch 0/6] mm: memcg naturalization
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bcd19c6a04a36e31d6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--000e0ce008bcd19c6a04a36e31d6
Content-Type: text/plain; charset=ISO-8859-1

On Fri, May 13, 2011 at 12:20 AM, Johannes Weiner <hannes@cmpxchg.org>wrote:

> On Thu, May 12, 2011 at 11:53:37AM -0700, Ying Han wrote:
> > On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner <hannes@cmpxchg.org>
> wrote:
> >
> > > Hi!
> > >
> > > Here is a patch series that is a result of the memcg discussions on
> > > LSF (memcg-aware global reclaim, global lru removal, struct
> > > page_cgroup reduction, soft limit implementation) and the recent
> > > feature discussions on linux-mm.
> > >
> > > The long-term idea is to have memcgs no longer bolted to the side of
> > > the mm code, but integrate it as much as possible such that there is a
> > > native understanding of containers, and that the traditional !memcg
> > > setup is just a singular group.  This series is an approach in that
> > > direction.
>

This sounds like a good long term plan. Now I would wonder should we take it
step by step by doing:

1. improving the existing soft_limit reclaim from RB-tree based to link-list
based, also in a round_robin fashion.
We can keep the existing APIs but only changing the underlying
implementation of  mem_cgroup_soft_limit_reclaim()

2. remove the global lru list after the first one being proved to be
efficient.

3. then have better integration of memcg reclaim to the mm code.

--Ying


> > >
> > > It is a rather early snapshot, WIP, barely tested etc., but I wanted
> > > to get your opinions before further pursuing it.  It is also part of
> > > my counter-argument to the proposals of adding memcg-reclaim-related
> > > user interfaces at this point in time, so I wanted to push this out
> > > the door before things are merged into .40.
> > >
> >
> > The memcg-reclaim-related user interface I assume was the watermark
> > configurable tunable we were talking about in the per-memcg
> > background reclaim patch. I think we got some agreement to remove
> > the watermark tunable at the first step. But the newly added
> > memory.soft_limit_async_reclaim as you proposed seems to be a usable
> > interface.
>
> Actually, I meant the soft limit reclaim statistics.  There is a
> comment about that in the 6/6 changelog.
>

Ok get it now. I will move the discussion to that thread.

--000e0ce008bcd19c6a04a36e31d6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, May 13, 2011 at 12:20 AM, Johann=
es Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hanne=
s@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Thu, May 12, 2011 at 11:53:37AM -0700, Ying Han wrote:=
<br>
&gt; On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner &lt;<a href=3D"mailto=
:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; Hi!<br>
&gt; &gt;<br>
&gt; &gt; Here is a patch series that is a result of the memcg discussions =
on<br>
&gt; &gt; LSF (memcg-aware global reclaim, global lru removal, struct<br>
&gt; &gt; page_cgroup reduction, soft limit implementation) and the recent<=
br>
&gt; &gt; feature discussions on linux-mm.<br>
&gt; &gt;<br>
&gt; &gt; The long-term idea is to have memcgs no longer bolted to the side=
 of<br>
&gt; &gt; the mm code, but integrate it as much as possible such that there=
 is a<br>
&gt; &gt; native understanding of containers, and that the traditional !mem=
cg<br>
&gt; &gt; setup is just a singular group. =A0This series is an approach in =
that<br>
&gt; &gt; direction.<br></div></blockquote><div><br></div><div>This sounds =
like a good long term plan. Now I would wonder should we take it step by st=
ep by doing:</div><div><br></div><div>1. improving the existing soft_limit =
reclaim from RB-tree based to link-list based, also in a round_robin fashio=
n.</div>
<div>We can keep the existing APIs but only changing the underlying impleme=
ntation of =A0mem_cgroup_soft_limit_reclaim()</div><div><br></div><div>2. r=
emove the global lru list after the first one being proved to be efficient.=
</div>
<div><br></div><div>3. then have better integration of memcg reclaim to the=
 mm code.</div><div><br></div><div>--Ying</div><div>=A0</div><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;p=
adding-left:1ex;">
<div class=3D"im">&gt; &gt;<br>
&gt; &gt; It is a rather early snapshot, WIP, barely tested etc., but I wan=
ted<br>
&gt; &gt; to get your opinions before further pursuing it. =A0It is also pa=
rt of<br>
&gt; &gt; my counter-argument to the proposals of adding memcg-reclaim-rela=
ted<br>
&gt; &gt; user interfaces at this point in time, so I wanted to push this o=
ut<br>
&gt; &gt; the door before things are merged into .40.<br>
&gt; &gt;<br>
&gt;<br>
&gt; The memcg-reclaim-related user interface I assume was the watermark<br=
>
&gt; configurable tunable we were talking about in the per-memcg<br>
&gt; background reclaim patch. I think we got some agreement to remove<br>
&gt; the watermark tunable at the first step. But the newly added<br>
&gt; memory.soft_limit_async_reclaim as you proposed seems to be a usable<b=
r>
&gt; interface.<br>
<br>
</div>Actually, I meant the soft limit reclaim statistics. =A0There is a<br=
>
comment about that in the 6/6 changelog.<br></blockquote><div><br></div><di=
v>Ok get it now. I will move the discussion to that thread.</div><div>=A0</=
div></div><br>

--000e0ce008bcd19c6a04a36e31d6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
