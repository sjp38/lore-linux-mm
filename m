Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id ACFB790010B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 20:05:24 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p4H059fc029841
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:05:09 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by wpaz37.hot.corp.google.com with ESMTP id p4H04YXj007672
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:05:08 -0700
Received: by qyk36 with SMTP id 36so2532737qyk.18
        for <linux-mm@kvack.org>; Mon, 16 May 2011 17:05:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110516231512.GW16531@cmpxchg.org>
References: <1305583230-2111-1-git-send-email-yinghan@google.com>
	<20110516231512.GW16531@cmpxchg.org>
Date: Mon, 16 May 2011 17:05:02 -0700
Message-ID: <BANLkTinohFTQRTViyU5NQ6EGi95xieXwOA@mail.gmail.com>
Subject: Re: [PATCH] memcg: fix typo in the soft_limit stats.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5c0dfb7404a36d8659
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5c0dfb7404a36d8659
Content-Type: text/plain; charset=ISO-8859-1

On Mon, May 16, 2011 at 4:15 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Mon, May 16, 2011 at 03:00:30PM -0700, Ying Han wrote:
> > This fixes the typo in the memory.stat including the following two
> > stats:
> >
> > $ cat /dev/cgroup/memory/A/memory.stat
> > total_soft_steal 0
> > total_soft_scan 0
> >
> > And change it to:
> >
> > $ cat /dev/cgroup/memory/A/memory.stat
> > total_soft_kswapd_steal 0
> > total_soft_kswapd_scan 0
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> I am currently proposing and working on a scheme that makes the soft
> limit not only a factor for global memory pressure, but for
> hierarchical reclaim in general, to prefer child memcgs during reclaim
> that are in excess of their soft limit.
>
> Because this means prioritizing memcgs over one another, rather than
> having explicit soft limit reclaim runs, there is no natural counter
> for pages reclaimed due to the soft limit anymore.
>
> Thus, for the patch that introduces this counter:
>
> Nacked-by: Johannes Weiner <hannes@cmpxchg.org>
>

This patch is fixing a typo of the stats being integrated into mmotm. Does
it make sense to fix the
existing stats first while we are discussing other approaches?

--Ying

--0016360e3f5c0dfb7404a36d8659
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, May 16, 2011 at 4:15 PM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Mon, May 16, 2011 at 03:00:30PM -0700, Ying Han wrote:=
<br>
&gt; This fixes the typo in the memory.stat including the following two<br>
&gt; stats:<br>
&gt;<br>
&gt; $ cat /dev/cgroup/memory/A/memory.stat<br>
&gt; total_soft_steal 0<br>
&gt; total_soft_scan 0<br>
&gt;<br>
&gt; And change it to:<br>
&gt;<br>
&gt; $ cat /dev/cgroup/memory/A/memory.stat<br>
&gt; total_soft_kswapd_steal 0<br>
&gt; total_soft_kswapd_scan 0<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div>I am currently proposing and working on a scheme that makes the soft<=
br>
limit not only a factor for global memory pressure, but for<br>
hierarchical reclaim in general, to prefer child memcgs during reclaim<br>
that are in excess of their soft limit.<br>
<br>
Because this means prioritizing memcgs over one another, rather than<br>
having explicit soft limit reclaim runs, there is no natural counter<br>
for pages reclaimed due to the soft limit anymore.<br>
<br>
Thus, for the patch that introduces this counter:<br>
<br>
Nacked-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;<br></blockquote><div><br></div><div>This patch is fixi=
ng a typo of the stats being integrated into mmotm. Does it make sense to f=
ix the</div>
<div>existing stats first while we are discussing other=A0approaches?</div>=
<div><br></div><div>--Ying</div><div>=A0</div></div><br>

--0016360e3f5c0dfb7404a36d8659--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
