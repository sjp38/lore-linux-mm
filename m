Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 36A716B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 22:54:58 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p4K2ss2Y003773
	for <linux-mm@kvack.org>; Thu, 19 May 2011 19:54:54 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by hpaq6.eem.corp.google.com with ESMTP id p4K2smRf013299
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 May 2011 19:54:53 -0700
Received: by qyk2 with SMTP id 2so53158qyk.0
        for <linux-mm@kvack.org>; Thu, 19 May 2011 19:54:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520111105.d6f5ca1b.nishimura@mxp.nes.nec.co.jp>
References: <1305826360-2167-1-git-send-email-yinghan@google.com>
	<1305826360-2167-2-git-send-email-yinghan@google.com>
	<20110520111105.d6f5ca1b.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 19 May 2011 19:54:46 -0700
Message-ID: <BANLkTin5h3Gh=Abi4jEMWq-mc-Uu8PF0xQ@mail.gmail.com>
Subject: Re: [PATCH V3 2/3] memcg: fix a routine for counting pages in node
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5c94710504a3ac3e96
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5c94710504a3ac3e96
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 19, 2011 at 7:11 PM, Daisuke Nishimura <
nishimura@mxp.nes.nec.co.jp> wrote:

> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>
> This is a bugfix for
> memcg-reclaim-memory-from-nodes-in-round-robin-order.patch
> in mmotm tree, so I think it would be better to note about it.
>

Sounds good, and I will add that comment in next post.

Thanks for reviewing it.

--Ying

>
> On Thu, 19 May 2011 10:32:39 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > The value for counter base should be initialized. If not,
> > this returns wrong value.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index da183dc..e14677c 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -679,7 +679,7 @@ static unsigned long
> >  mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum
> lru_list idx)
> >  {
> >       struct mem_cgroup_per_zone *mz;
> > -     u64 total;
> > +     u64 total = 0;
> >       int zid;
> >
> >       for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> > --
> > 1.7.3.1
> >
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--0016360e3f5c94710504a3ac3e96
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 19, 2011 at 7:11 PM, Daisuke=
 Nishimura <span dir=3D"ltr">&lt;<a href=3D"mailto:nishimura@mxp.nes.nec.co=
.jp" target=3D"_blank">nishimura@mxp.nes.nec.co.jp</a>&gt;</span> wrote:<br=
><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1=
px #ccc solid;padding-left:1ex">

Acked-by: Daisuke Nishimura &lt;<a href=3D"mailto:nishimura@mxp.nes.nec.co.=
jp" target=3D"_blank">nishimura@mxp.nes.nec.co.jp</a>&gt;<br>
<br>
This is a bugfix for memcg-reclaim-memory-from-nodes-in-round-robin-order.p=
atch<br>
in mmotm tree, so I think it would be better to note about it.<br></blockqu=
ote><div><br></div><div>Sounds good, and I will add that comment in next po=
st.</div><div><br></div><div>Thanks for reviewing it.</div><div><br></div>
<div>--Ying=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div><div></div><div><br>
On Thu, 19 May 2011 10:32:39 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com" target=3D"_blank">yingha=
n@google.com</a>&gt; wrote:<br>
<br>
&gt; The value for counter base should be initialized. If not,<br>
&gt; this returns wrong value.<br>
&gt;<br>
&gt; Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu=
@jp.fujitsu.com" target=3D"_blank">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<b=
r>
&gt; ---<br>
&gt; =A0mm/memcontrol.c | =A0 =A02 +-<br>
&gt; =A01 files changed, 1 insertions(+), 1 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index da183dc..e14677c 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -679,7 +679,7 @@ static unsigned long<br>
&gt; =A0mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum =
lru_list idx)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
&gt; - =A0 =A0 u64 total;<br>
&gt; + =A0 =A0 u64 total =3D 0;<br>
&gt; =A0 =A0 =A0 int zid;<br>
&gt;<br>
&gt; =A0 =A0 =A0 for (zid =3D 0; zid &lt; MAX_NR_ZONES; zid++) {<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
<br>
</div></div><font color=3D"#888888">--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org" target=3D"_blank">majord=
omo@kvack.org</a>. =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Fight unfair telecom internet charges in Canada: sign <a href=3D"http://sto=
pthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
" target=3D"_blank">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kv=
ack.org" target=3D"_blank">email@kvack.org</a> &lt;/a&gt;<br>
</font></blockquote></div><br>

--0016360e3f5c94710504a3ac3e96--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
