Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 26B916B0024
	for <linux-mm@kvack.org>; Fri, 20 May 2011 00:03:36 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p4K43S4g012658
	for <linux-mm@kvack.org>; Thu, 19 May 2011 21:03:33 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by kpbe17.cbf.corp.google.com with ESMTP id p4K43QOP030924
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 May 2011 21:03:27 -0700
Received: by qyk10 with SMTP id 10so2254613qyk.11
        for <linux-mm@kvack.org>; Thu, 19 May 2011 21:03:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520125046.963d06e9.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305861891-26140-1-git-send-email-yinghan@google.com>
	<1305861891-26140-3-git-send-email-yinghan@google.com>
	<20110520125046.963d06e9.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 19 May 2011 21:03:26 -0700
Message-ID: <BANLkTimZb32bBeQR=n2o9zGx4BFLMHq08Q@mail.gmail.com>
Subject: Re: [PATCH V4 3/3] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc2673df04a3ad3447
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0ce008bc2673df04a3ad3447
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 19, 2011 at 8:50 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 19 May 2011 20:24:51 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > The new API exports numa_maps per-memcg basis. This is a piece of useful
> > information where it exports per-memcg page distribution across real numa
> > nodes.
> >
> > One of the usecase is evaluating application performance by combining
> this
> > information w/ the cpu allocation to the application.
> >
> > The output of the memory.numastat tries to follow w/ simiar format of
> numa_maps
> > like:
> >
> > total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> >
> > And we have per-node:
> > total = file + anon + unevictable
> >
> > $ cat /dev/cgroup/memory/memory.numa_stat
> > total=250020 N0=87620 N1=52367 N2=45298 N3=64735
> > file=225232 N0=83402 N1=46160 N2=40522 N3=55148
> > anon=21053 N0=3424 N1=6207 N2=4776 N3=6646
> > unevictable=3735 N0=794 N1=0 N2=0 N3=2941
> >
> > change v4..v3:
> > 1. add per-node "unevictable" value.
> > 2. change the functions to be static.
> >
> > change v3..v2:
> > 1. calculate the "total" based on the per-memcg lru size instead of
> rss+cache.
> > this makes the "total" value to be consistant w/ the per-node values
> follows
> > after.
> >
> > change v2..v1:
> > 1. add also the file and anon pages on per-node distribution.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> Seems fine. Thank you for patient work.
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>

Sure. thank you for reviewing it.

Thanks

--Ying

--000e0ce008bc2673df04a3ad3447
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 19, 2011 at 8:50 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Thu, 19 May 2011 20:24:51 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; The new API exports numa_maps per-memcg basis. This is a piece of usef=
ul<br>
&gt; information where it exports per-memcg page distribution across real n=
uma<br>
&gt; nodes.<br>
&gt;<br>
&gt; One of the usecase is evaluating application performance by combining =
this<br>
&gt; information w/ the cpu allocation to the application.<br>
&gt;<br>
&gt; The output of the memory.numastat tries to follow w/ simiar format of =
numa_maps<br>
&gt; like:<br>
&gt;<br>
&gt; total=3D&lt;total pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;node 1 =
pages&gt; ...<br>
&gt; file=3D&lt;total file pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;nod=
e 1 pages&gt; ...<br>
&gt; anon=3D&lt;total anon pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;nod=
e 1 pages&gt; ...<br>
&gt; unevictable=3D&lt;total anon pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D=
&lt;node 1 pages&gt; ...<br>
&gt;<br>
&gt; And we have per-node:<br>
&gt; total =3D file + anon + unevictable<br>
&gt;<br>
&gt; $ cat /dev/cgroup/memory/memory.numa_stat<br>
&gt; total=3D250020 N0=3D87620 N1=3D52367 N2=3D45298 N3=3D64735<br>
&gt; file=3D225232 N0=3D83402 N1=3D46160 N2=3D40522 N3=3D55148<br>
&gt; anon=3D21053 N0=3D3424 N1=3D6207 N2=3D4776 N3=3D6646<br>
&gt; unevictable=3D3735 N0=3D794 N1=3D0 N2=3D0 N3=3D2941<br>
&gt;<br>
&gt; change v4..v3:<br>
&gt; 1. add per-node &quot;unevictable&quot; value.<br>
&gt; 2. change the functions to be static.<br>
&gt;<br>
&gt; change v3..v2:<br>
&gt; 1. calculate the &quot;total&quot; based on the per-memcg lru size ins=
tead of rss+cache.<br>
&gt; this makes the &quot;total&quot; value to be consistant w/ the per-nod=
e values follows<br>
&gt; after.<br>
&gt;<br>
&gt; change v2..v1:<br>
&gt; 1. add also the file and anon pages on per-node distribution.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div></div>Seems fine. Thank you for patient work.<br>
<br>
Acked-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujits=
u.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br></blockquote><div><br></di=
v><div>Sure. thank you for reviewing it.</div><div><br></div><div>Thanks</d=
iv>
<div><br></div><div>--Ying=A0</div></div><br>

--000e0ce008bc2673df04a3ad3447--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
