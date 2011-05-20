Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFFC6B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 21:31:51 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p4K1Vljp027949
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:31:47 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by hpaq7.eem.corp.google.com with ESMTP id p4K1Vf6c002936
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:31:46 -0700
Received: by qyg14 with SMTP id 14so2128042qyg.5
        for <linux-mm@kvack.org>; Thu, 19 May 2011 18:31:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520092424.1f1b514f.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305826360-2167-1-git-send-email-yinghan@google.com>
	<1305826360-2167-3-git-send-email-yinghan@google.com>
	<20110520085152.e518ac71.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTincQttGR_o3Q6dxsq91+Ew12gYEOg@mail.gmail.com>
	<20110520092424.1f1b514f.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 19 May 2011 18:31:41 -0700
Message-ID: <BANLkTimtH6r09w8Em1gCh4VvWHV9P89cmQ@mail.gmail.com>
Subject: Re: [PATCH V3 3/3] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0015175d015e6e420204a3ab1517
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0015175d015e6e420204a3ab1517
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 19, 2011 at 5:24 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 19 May 2011 17:11:49 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Thu, May 19, 2011 at 4:51 PM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > > On Thu, 19 May 2011 10:32:40 -0700
> > > Ying Han <yinghan@google.com> wrote:
> > >
> > > > The new API exports numa_maps per-memcg basis. This is a piece of
> useful
> > > > information where it exports per-memcg page distribution across real
> numa
> > > > nodes.
> > > >
> > > > One of the usecase is evaluating application performance by combining
> > > this
> > > > information w/ the cpu allocation to the application.
> > > >
> > > > The output of the memory.numastat tries to follow w/ simiar format of
> > > numa_maps
> > > > like:
> > > >
> > > > total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > > > file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > > > anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > > >
> > > > $ cat /dev/cgroup/memory/memory.numa_stat
> > > > total=246594 N0=18225 N1=72025 N2=26378 N3=129966
> > > > file=221728 N0=15030 N1=60804 N2=23238 N3=122656
> > > > anon=21120 N0=2937 N1=7733 N2=3140 N3=7310
> > > >
> > >
> > > Hmm ? this doesn't seem consistent....Isn't this log updated ?
> > >
> >
> > Nope. This is the V3 i posted w/ updated testing result.
> >
>
> Did you get this log while applications are running and LRU are changing ?
> See N1, 72505 != 60804 + 7733. big error.
>

Could you clarify why total != file + anon ?
> Does the number seems consistent when the system is calm ?
>

 That is because the total includes "unevictable" which is not listed here
as "file" and "anon"

>
>
> BTW, I wonder why unevictable is not shown...
> mem_cgroup_node_nr_lru_pages() counts unevictable into it because of
> for_each_lru().
>
> There are 2 ways.
>  1. show unevictable
>  2. use for_each_evictable_lru().
>
> I vote for 1.
>

Sounds good to me, I can add the "unevictable" following the "file" and
"anon" on the next post.

Thanks for the review

--Ying

>
>
> Thanks,
> -Kame
>
>
>

--0015175d015e6e420204a3ab1517
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 19, 2011 at 5:24 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
On Thu, 19 May 2011 17:11:49 -0700<br>
<div class=3D"im">Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yingha=
n@google.com</a>&gt; wrote:<br>
<br>
&gt; On Thu, May 19, 2011 at 4:51 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Thu, 19 May 2011 10:32:40 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; The new API exports numa_maps per-memcg basis. This is a pie=
ce of useful<br>
&gt; &gt; &gt; information where it exports per-memcg page distribution acr=
oss real numa<br>
&gt; &gt; &gt; nodes.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; One of the usecase is evaluating application performance by =
combining<br>
&gt; &gt; this<br>
&gt; &gt; &gt; information w/ the cpu allocation to the application.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; The output of the memory.numastat tries to follow w/ simiar =
format of<br>
&gt; &gt; numa_maps<br>
&gt; &gt; &gt; like:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; total=3D&lt;total pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&=
lt;node 1 pages&gt; ...<br>
&gt; &gt; &gt; file=3D&lt;total file pages&gt; N0=3D&lt;node 0 pages&gt; N1=
=3D&lt;node 1 pages&gt; ...<br>
&gt; &gt; &gt; anon=3D&lt;total anon pages&gt; N0=3D&lt;node 0 pages&gt; N1=
=3D&lt;node 1 pages&gt; ...<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; $ cat /dev/cgroup/memory/memory.numa_stat<br>
&gt; &gt; &gt; total=3D246594 N0=3D18225 N1=3D72025 N2=3D26378 N3=3D129966<=
br>
&gt; &gt; &gt; file=3D221728 N0=3D15030 N1=3D60804 N2=3D23238 N3=3D122656<b=
r>
&gt; &gt; &gt; anon=3D21120 N0=3D2937 N1=3D7733 N2=3D3140 N3=3D7310<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Hmm ? this doesn&#39;t seem consistent....Isn&#39;t this log upda=
ted ?<br>
&gt; &gt;<br>
&gt;<br>
&gt; Nope. This is the V3 i posted w/ updated testing result.<br>
&gt;<br>
<br>
</div>Did you get this log while applications are running and LRU are chang=
ing ?<br>
See N1, 72505 !=3D 60804 + 7733. big error.<br></blockquote><div><br></div>=
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">Could you clarify why total !=3D file + ano=
n ?<br>

Does the number seems consistent when the system is calm ?<br></blockquote>=
<div><br></div><div>=A0That is because the total includes &quot;unevictable=
&quot; which is not listed here as &quot;file&quot; and &quot;anon&quot;</d=
iv>
<meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-8"><b=
lockquote class=3D"gmail_quote" style=3D"margin-top: 0px; margin-right: 0px=
; margin-bottom: 0px; margin-left: 0.8ex; border-left-width: 1px; border-le=
ft-color: rgb(204, 204, 204); border-left-style: solid; padding-left: 1ex; =
">
<br></blockquote><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
BTW, I wonder why unevictable is not shown...<br>
mem_cgroup_node_nr_lru_pages() counts unevictable into it because of for_ea=
ch_lru().<br>
<br>
There are 2 ways.<br>
=A01. show unevictable<br>
=A02. use for_each_evictable_lru().<br>
<br>
I vote for 1.<br></blockquote><div><br></div><div>Sounds good to me, I can =
add the &quot;unevictable&quot; following the &quot;file&quot; and &quot;an=
on&quot; on the next post.</div><div><br></div><div>Thanks for the review</=
div>
<div><br></div><div>--Ying</div><meta http-equiv=3D"content-type" content=
=3D"text/html; charset=3Dutf-8"><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
<br>
Thanks,<br>
-Kame<br>
<br>
<br>
</blockquote></div><br>

--0015175d015e6e420204a3ab1517--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
