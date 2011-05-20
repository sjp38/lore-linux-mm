Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 96C00900114
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:00:54 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p4KL0Z5A009459
	for <linux-mm@kvack.org>; Fri, 20 May 2011 14:00:45 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by kpbe12.cbf.corp.google.com with ESMTP id p4KKxSgt030683
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 20 May 2011 14:00:25 -0700
Received: by qwk3 with SMTP id 3so2732865qwk.5
        for <linux-mm@kvack.org>; Fri, 20 May 2011 14:00:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520132051.28c1bc15.akpm@linux-foundation.org>
References: <1305861891-26140-1-git-send-email-yinghan@google.com>
	<1305861891-26140-3-git-send-email-yinghan@google.com>
	<20110520132051.28c1bc15.akpm@linux-foundation.org>
Date: Fri, 20 May 2011 14:00:19 -0700
Message-ID: <BANLkTimov7zdGJdj59WjLXQ47pOJi2UoeA@mail.gmail.com>
Subject: Re: [PATCH V4 3/3] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa8d5cb5d04a3bb68c8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--002354470aa8d5cb5d04a3bb68c8
Content-Type: text/plain; charset=ISO-8859-1

On Fri, May 20, 2011 at 1:20 PM, Andrew Morton <akpm@linux-foundation.org>wrote:

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
>
> Does it make sense to add all this code for non-NUMA kernels?
>
> The patch adds a kilobyte of pretty useless text to uniprocessor kernels.
>

Thanks Andrew. I will upload another patch adding "#ifdef CONFIG_NUMA" on
the API

Thanks

--Ying

--002354470aa8d5cb5d04a3bb68c8
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, May 20, 2011 at 1:20 PM, Andrew =
Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org">a=
kpm@linux-foundation.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex;">
<div class=3D"im">On Thu, 19 May 2011 20:24:51 -0700<br>
</div><div class=3D"im">Ying Han &lt;<a href=3D"mailto:yinghan@google.com">=
yinghan@google.com</a>&gt; wrote:<br>
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
<br>
</div>Does it make sense to add all this code for non-NUMA kernels?<br>
<br>
The patch adds a kilobyte of pretty useless text to uniprocessor kernels.<b=
r></blockquote><div><br></div><div>Thanks Andrew. I will upload another pat=
ch adding &quot;#ifdef CONFIG_NUMA&quot; on the API</div><div><br></div>
<div>Thanks</div><div><br></div><div>--Ying=A0</div></div><br>

--002354470aa8d5cb5d04a3bb68c8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
