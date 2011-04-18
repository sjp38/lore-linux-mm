Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 41206900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 13:42:02 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p3IHfrmu022372
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:41:53 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by kpbe12.cbf.corp.google.com with ESMTP id p3IHdNvc028088
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:41:51 -0700
Received: by qyg14 with SMTP id 14so3155176qyg.19
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:41:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTik5g_+7KYVRM8tmpHzM55vjekk1EA@mail.gmail.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-10-git-send-email-yinghan@google.com>
	<BANLkTik5g_+7KYVRM8tmpHzM55vjekk1EA@mail.gmail.com>
Date: Mon, 18 Apr 2011 10:41:51 -0700
Message-ID: <BANLkTi=_qJe8OVPdKP9zozetAnaPM_oAmA@mail.gmail.com>
Subject: Re: [PATCH V5 09/10] Add API to export per-memcg kswapd pid.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=20cf300fab971cccc604a134e87c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--20cf300fab971cccc604a134e87c
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Apr 17, 2011 at 10:01 PM, Minchan Kim <minchan.kim@gmail.com> wrote:

> On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
> > This add the API which exports per-memcg kswapd thread pid. The kswapd
> > thread is named as "memcg_" + css_id, and the pid can be used to put
> > kswapd thread into cpu cgroup later.
> >
> > $ mkdir /dev/cgroup/memory/A
> > $ cat /dev/cgroup/memory/A/memory.kswapd_pid
> > memcg_null 0
> >
> > $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> > $ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
> > $ ps -ef | grep memcg
> > root      6727     2  0 14:32 ?        00:00:00 [memcg_3]
> > root      6729  6044  0 14:32 ttyS0    00:00:00 grep memcg
> >
> > $ cat memory.kswapd_pid
> > memcg_3 6727
> >
> > changelog v5..v4
> > 1. Initialize the memcg-kswapd pid to -1 instead of 0.
> > 2. Remove the kswapds_spinlock.
> >
> > changelog v4..v3
> > 1. Add the API based on KAMAZAWA's request on patch v3.
> >
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  include/linux/swap.h |    2 ++
> >  mm/memcontrol.c      |   31 +++++++++++++++++++++++++++++++
> >  2 files changed, 33 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 319b800..2d3e21a 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -34,6 +34,8 @@ struct kswapd {
> >  };
> >
> >  int kswapd(void *p);
> > +extern spinlock_t kswapds_spinlock;
>
> Remove spinlock.
>

Thanks. Will remove from the next post.

--Ying

>
>
>
> --
> Kind regards,
> Minchan Kim
>

--20cf300fab971cccc604a134e87c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sun, Apr 17, 2011 at 10:01 PM, Mincha=
n Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan.kim@gmail.com">mincha=
n.kim@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" =
style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Sat, Apr 16, 2011 at 8:23 AM, Ying Han=
 &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&gt; wrote=
:<br>
&gt; This add the API which exports per-memcg kswapd thread pid. The kswapd=
<br>
&gt; thread is named as &quot;memcg_&quot; + css_id, and the pid can be use=
d to put<br>
&gt; kswapd thread into cpu cgroup later.<br>
&gt;<br>
&gt; $ mkdir /dev/cgroup/memory/A<br>
&gt; $ cat /dev/cgroup/memory/A/memory.kswapd_pid<br>
&gt; memcg_null 0<br>
&gt;<br>
&gt; $ echo 500m &gt;/dev/cgroup/memory/A/memory.limit_in_bytes<br>
&gt; $ echo 50m &gt;/dev/cgroup/memory/A/memory.high_wmark_distance<br>
&gt; $ ps -ef | grep memcg<br>
&gt; root =A0 =A0 =A06727 =A0 =A0 2 =A00 14:32 ? =A0 =A0 =A0 =A000:00:00 [m=
emcg_3]<br>
&gt; root =A0 =A0 =A06729 =A06044 =A00 14:32 ttyS0 =A0 =A000:00:00 grep mem=
cg<br>
&gt;<br>
&gt; $ cat memory.kswapd_pid<br>
&gt; memcg_3 6727<br>
&gt;<br>
&gt; changelog v5..v4<br>
&gt; 1. Initialize the memcg-kswapd pid to -1 instead of 0.<br>
&gt; 2. Remove the kswapds_spinlock.<br>
&gt;<br>
&gt; changelog v4..v3<br>
&gt; 1. Add the API based on KAMAZAWA&#39;s request on patch v3.<br>
&gt;<br>
&gt; Reviewed-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@j=
p.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0include/linux/swap.h | =A0 =A02 ++<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0| =A0 31 +++++++++++++++++++++++++++++++=
<br>
&gt; =A02 files changed, 33 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
&gt; index 319b800..2d3e21a 100644<br>
&gt; --- a/include/linux/swap.h<br>
&gt; +++ b/include/linux/swap.h<br>
&gt; @@ -34,6 +34,8 @@ struct kswapd {<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0int kswapd(void *p);<br>
&gt; +extern spinlock_t kswapds_spinlock;<br>
<br>
</div></div>Remove spinlock.<br></blockquote><div><br></div><div>Thanks. Wi=
ll remove from the next post.</div><div><br></div><div>--Ying=A0</div><bloc=
kquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #cc=
c solid;padding-left:1ex;">

<br>
<br>
<br>
--<br>
Kind regards,<br>
<font color=3D"#888888">Minchan Kim<br>
</font></blockquote></div><br>

--20cf300fab971cccc604a134e87c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
