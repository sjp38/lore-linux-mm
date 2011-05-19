Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 409496B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:36:44 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p4JFaf3J023395
	for <linux-mm@kvack.org>; Thu, 19 May 2011 08:36:41 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by kpbe12.cbf.corp.google.com with ESMTP id p4JFaZjs012367
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 May 2011 08:36:40 -0700
Received: by qyg14 with SMTP id 14so1604612qyg.19
        for <linux-mm@kvack.org>; Thu, 19 May 2011 08:36:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110519080135.GE3139@balbir.in.ibm.com>
References: <1305766511-11469-1-git-send-email-yinghan@google.com>
	<1305766511-11469-2-git-send-email-yinghan@google.com>
	<20110519080135.GE3139@balbir.in.ibm.com>
Date: Thu, 19 May 2011 08:36:35 -0700
Message-ID: <BANLkTin1L7W6w+9_7GiqjrbSXDa0G5th0A@mail.gmail.com>
Subject: Re: [PATCH V2 2/2] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5c32db6904a3a2c5be
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5c32db6904a3a2c5be
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 19, 2011 at 1:01 AM, Balbir Singh <balbir@linux.vnet.ibm.com>wrote:

> * Ying Han <yinghan@google.com> [2011-05-18 17:55:11]:
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
> >
>
> That seems like a good idea, so +1 for we need to do this.
>

Thanks for the +1 :)


>
> > $ cat /dev/cgroup/memory/memory.numa_stat
> > total=317674 N0=101850 N1=72552 N2=30120 N3=113142
> > file=288219 N0=98046 N1=59220 N2=23578 N3=107375
> > anon=25699 N0=3804 N1=10124 N2=6540 N3=5231
> >
> > Note: I noticed <total pages> is not equal to the sum of the rest of
> counters.
> > I might need to change the way get that counter, comments are welcomed.
> >
>
> Can you see if the total is greater or lesser than the actual value?
> Do you have any pages mlocked?
>

As i replied Daisuke, i think the problem is some pages charged to the memcg
might not on the LRU.

--Ying

>
> > change v2..v1:
> > 1. add also the file and anon pages on per-node distribution.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  mm/memcontrol.c |  109
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 109 insertions(+), 0 deletions(-)
> >
> --
>        Three Cheers,
>         Balbir
>

--0016360e3f5c32db6904a3a2c5be
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 19, 2011 at 1:01 AM, Balbir =
Singh <span dir=3D"ltr">&lt;<a href=3D"mailto:balbir@linux.vnet.ibm.com">ba=
lbir@linux.vnet.ibm.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;">
* Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>=
&gt; [2011-05-18 17:55:11]:<br>
<div class=3D"im"><br>
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
&gt;<br>
<br>
</div>That seems like a good idea, so +1 for we need to do this.<br></block=
quote><div><br></div><div>Thanks for the +1 :)</div><div>=A0</div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex;">

<div class=3D"im"><br>
&gt; $ cat /dev/cgroup/memory/memory.numa_stat<br>
&gt; total=3D317674 N0=3D101850 N1=3D72552 N2=3D30120 N3=3D113142<br>
&gt; file=3D288219 N0=3D98046 N1=3D59220 N2=3D23578 N3=3D107375<br>
&gt; anon=3D25699 N0=3D3804 N1=3D10124 N2=3D6540 N3=3D5231<br>
&gt;<br>
&gt; Note: I noticed &lt;total pages&gt; is not equal to the sum of the res=
t of counters.<br>
&gt; I might need to change the way get that counter, comments are welcomed=
.<br>
&gt;<br>
<br>
</div>Can you see if the total is greater or lesser than the actual value?<=
br>
Do you have any pages mlocked?<br></blockquote><div><br></div><div>As i rep=
lied Daisuke, i think the problem is some pages charged to the memcg might =
not on the LRU.</div><div><br></div><div>--Ying</div><blockquote class=3D"g=
mail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-l=
eft:1ex;">

<div class=3D"im"><br>
&gt; change v2..v1:<br>
&gt; 1. add also the file and anon pages on per-node distribution.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0mm/memcontrol.c | =A0109 ++++++++++++++++++++++++++++++++++++++++++=
+++++++++++++<br>
&gt; =A01 files changed, 109 insertions(+), 0 deletions(-)<br>
&gt;<br>
</div>--<br>
 =A0 =A0 =A0 =A0Three Cheers,<br>
<font color=3D"#888888"> =A0 =A0 =A0 =A0Balbir<br>
</font></blockquote></div><br>

--0016360e3f5c32db6904a3a2c5be--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
