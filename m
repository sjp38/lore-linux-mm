Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 25B67900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 13:11:17 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p3IHB6qo002225
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:11:06 -0700
Received: from qwi2 (qwi2.prod.google.com [10.241.195.2])
	by hpaq11.eem.corp.google.com with ESMTP id p3IH8QuB029455
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:11:01 -0700
Received: by qwi2 with SMTP id 2so4157308qwi.22
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:11:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTing7E=7HZ25uTvwVHwYV5c-6-uvjg@mail.gmail.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-6-git-send-email-yinghan@google.com>
	<BANLkTing7E=7HZ25uTvwVHwYV5c-6-uvjg@mail.gmail.com>
Date: Mon, 18 Apr 2011 10:11:00 -0700
Message-ID: <BANLkTin6GqsmhAE3JJyO0AJBO3ht_TFA4w@mail.gmail.com>
Subject: Re: [PATCH V5 05/10] Implement the select_victim_node within memcg.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee0c9fc3604a13479ff
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cd68ee0c9fc3604a13479ff
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Apr 17, 2011 at 7:22 PM, Minchan Kim <minchan.kim@gmail.com> wrote:

> On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
> > This add the mechanism for background reclaim which we remember the
> > last scanned node and always starting from the next one each time.
> > The simple round-robin fasion provide the fairness between nodes for
> > each memcg.
> >
> > changelog v5..v4:
> > 1. initialize the last_scanned_node to MAX_NUMNODES.
> >
> > changelog v4..v3:
> > 1. split off from the per-memcg background reclaim patch.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  include/linux/memcontrol.h |    3 +++
> >  mm/memcontrol.c            |   35 +++++++++++++++++++++++++++++++++++
> >  2 files changed, 38 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index f7ffd1f..d4ff7f2 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -88,6 +88,9 @@ extern int mem_cgroup_init_kswapd(struct mem_cgroup
> *mem,
> >                                  struct kswapd *kswapd_p);
> >  extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
> >  extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup
> *mem);
> > +extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
> > +extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
> > +                                       const nodemask_t *nodes);
> >
> >  static inline
> >  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 8761a6f..b92dc13 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -279,6 +279,11 @@ struct mem_cgroup {
> >        u64 high_wmark_distance;
> >        u64 low_wmark_distance;
> >
> > +       /* While doing per cgroup background reclaim, we cache the
>
> Correct comment style.
>
> Thanks. Will change in the next post.

--Ying

> --
> Kind regards,
> Minchan Kim
>

--000e0cd68ee0c9fc3604a13479ff
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sun, Apr 17, 2011 at 7:22 PM, Minchan=
 Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan.kim@gmail.com">minchan=
.kim@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Sat, Apr 16, 2011 at 8:23 AM, Ying Han=
 &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&gt; wrote=
:<br>
&gt; This add the mechanism for background reclaim which we remember the<br=
>
&gt; last scanned node and always starting from the next one each time.<br>
&gt; The simple round-robin fasion provide the fairness between nodes for<b=
r>
&gt; each memcg.<br>
&gt;<br>
&gt; changelog v5..v4:<br>
&gt; 1. initialize the last_scanned_node to MAX_NUMNODES.<br>
&gt;<br>
&gt; changelog v4..v3:<br>
&gt; 1. split off from the per-memcg background reclaim patch.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h | =A0 =A03 +++<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 35 +++++++++++++++++++=
++++++++++++++++<br>
&gt; =A02 files changed, 38 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<b=
r>
&gt; index f7ffd1f..d4ff7f2 100644<br>
&gt; --- a/include/linux/memcontrol.h<br>
&gt; +++ b/include/linux/memcontrol.h<br>
&gt; @@ -88,6 +88,9 @@ extern int mem_cgroup_init_kswapd(struct mem_cgroup =
*mem,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0str=
uct kswapd *kswapd_p);<br>
&gt; =A0extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);<br>
&gt; =A0extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup =
*mem);<br>
&gt; +extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);<br>
&gt; +extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 const nodemask_t *nodes);<br>
&gt;<br>
&gt; =A0static inline<br>
&gt; =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cg=
roup *cgroup)<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 8761a6f..b92dc13 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -279,6 +279,11 @@ struct mem_cgroup {<br>
&gt; =A0 =A0 =A0 =A0u64 high_wmark_distance;<br>
&gt; =A0 =A0 =A0 =A0u64 low_wmark_distance;<br>
&gt;<br>
&gt; + =A0 =A0 =A0 /* While doing per cgroup background reclaim, we cache t=
he<br>
<br>
</div></div>Correct comment style.<br>
<br></blockquote><div>Thanks. Will change in the next post.</div><div><br><=
/div><div>--Ying=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
--<br>
Kind regards,<br>
<font color=3D"#888888">Minchan Kim<br>
</font></blockquote></div><br>

--000e0cd68ee0c9fc3604a13479ff--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
