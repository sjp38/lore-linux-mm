Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6178D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 02:00:24 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p3M60MuT024160
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 23:00:22 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by kpbe15.cbf.corp.google.com with ESMTP id p3M603wV004196
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 23:00:21 -0700
Received: by qyk7 with SMTP id 7so216252qyk.17
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 23:00:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110422142734.FA69.A69D9226@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-6-git-send-email-yinghan@google.com>
	<20110422142734.FA69.A69D9226@jp.fujitsu.com>
Date: Thu, 21 Apr 2011 23:00:20 -0700
Message-ID: <BANLkTimfF4YKPZxW=L5y+1hu3w8TYzyD6g@mail.gmail.com>
Subject: Re: [PATCH V7 5/9] Infrastructure to support per-memcg reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bcae9a9604a17b9272
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0ce008bcae9a9604a17b9272
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 21, 2011 at 10:27 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> > +static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, int
> order)
> > +{
> > +     return 0;
> > +}
>
> this one and
>
> > @@ -2672,36 +2686,48 @@ int kswapd(void *p)
> (snip)
> >               /*
> >                * We can speed up thawing tasks if we don't call
> balance_pgdat
> >                * after returning from the refrigerator
> >                */
> > -             if (!ret) {
> > +             if (is_global_kswapd(kswapd_p)) {
> >                       trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> >                       order = balance_pgdat(pgdat, order,
> &classzone_idx);
> > +             } else {
> > +                     mem = mem_cgroup_get_shrink_target();
> > +                     if (mem)
> > +                             shrink_mem_cgroup(mem, order);
> > +                     mem_cgroup_put_shrink_target(mem);
> >               }
> >       }
>
> this one shold be placed in "[7/9] Per-memcg background reclaim". isn't it?
>

This is the infrastructure, and the shrink_mem_cgroup() is a noop. The [7/9]
is the actual implementation.

--Ying

--000e0ce008bcae9a9604a17b9272
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 21, 2011 at 10:27 PM, KOSAKI=
 Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujits=
u.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote =
class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid=
;padding-left:1ex;">
<div class=3D"im">&gt; +static unsigned long shrink_mem_cgroup(struct mem_c=
group *mem_cont, int order)<br>
&gt; +{<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
<br>
</div>this one and<br>
<div class=3D"im"><br>
&gt; @@ -2672,36 +2686,48 @@ int kswapd(void *p)<br>
</div>(snip)<br>
<div class=3D"im">&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We can speed up thawing tasks if we d=
on&#39;t call balance_pgdat<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* after returning from the refrigerator=
<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 if (!ret) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (is_global_kswapd(kswapd_p)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_wak=
e(pgdat-&gt;node_id, order);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D balance_pgdat(pg=
dat, order, &amp;classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D mem_cgroup_get_shrin=
k_target();<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_c=
group(mem, order);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_put_shrink_target=
(mem);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 }<br>
<br>
</div>this one shold be placed in &quot;[7/9] Per-memcg background reclaim&=
quot;. isn&#39;t it?<br></blockquote><div><br></div><div>This is the infras=
tructure, and the shrink_mem_cgroup() is a noop. The [7/9] is the actual im=
plementation.</div>
<div><br></div><div>--Ying=A0</div></div><br>

--000e0ce008bcae9a9604a17b9272--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
