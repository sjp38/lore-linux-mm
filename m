Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 22B498D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:24:13 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p3L4O9OK024499
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:24:09 -0700
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by hpaq2.eem.corp.google.com with ESMTP id p3L4NV9V008946
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:24:08 -0700
Received: by qyl38 with SMTP id 38so972007qyl.15
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 21:24:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
	<20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 20 Apr 2011 21:24:07 -0700
Message-ID: <BANLkTimp+=soLEH7M8yUpsLLssjgyKrL4w@mail.gmail.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bcb7fbc404a1661c8f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0ce008bcb7fbc404a1661c8f
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 20, 2011 at 9:00 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 21 Apr 2011 04:51:07 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> > > If the cgroup is configured to use per cgroup background reclaim, a
> kswapd
> > > thread is created which only scans the per-memcg LRU list.
> >
> > We already have direct reclaim, direct reclaim on behalf of a memcg,
> > and global kswapd-reclaim.  Please don't add yet another reclaim path
> > that does its own thing and interacts unpredictably with the rest of
> > them.
> >
> > As discussed on LSF, we want to get rid of the global LRU.  So the
> > goal is to have each reclaim entry end up at the same core part of
> > reclaim that round-robin scans a subset of zones from a subset of
> > memory control groups.
> >
>
> It's not related to this set. And I think even if we remove global LRU,
> global-kswapd and memcg-kswapd need to do independent work.
>
> global-kswapd : works for zone/node balancing and making free pages,
>                and compaction. select a memcg vicitm and ask it
>                to reduce memory with regard to gfp_mask. Starts its work
>                when zone/node is unbalanced.
>
> memcg-kswapd  : works for reducing usage of memory, no interests on
>                zone/nodes. Starts when high/low watermaks hits.
>
> We can share 'recalim_memcg_this_zone()' code finally, but it can be
> changed when we remove global LRU.
>
>
> > > Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> > > background reclaim and stop it. The watermarks are calculated based
> > > on the cgroup's limit_in_bytes.
> >
> > Which brings me to the next issue: making the watermarks configurable.
> >
> > You argued that having them adjustable from userspace is required for
> > overcommitting the hardlimits and per-memcg kswapd reclaim not kicking
> > in in case of global memory pressure.  But that is only a problem
> > because global kswapd reclaim is (apart from soft limit reclaim)
> > unaware of memory control groups.
> >
> > I think the much better solution is to make global kswapd memcg aware
> > (with the above mentioned round-robin reclaim scheduler), compared to
> > adding new (and final!) kernel ABI to avoid an internal shortcoming.
> >
>
> I don't think its a good idea to kick kswapd even when free memory is
> enough.
>
> If memcg-kswapd implemted, I'd like to add auto-cgroup for memcg-kswapd and
> limit its cpu usage because it works even when memory is not in-short.
>

How are we gonna isolate the memcg-kswapd cpu usage under the workqueue
model?

--Ying

>
>
> Thanks,
> -Kame
>
>
>

--000e0ce008bcb7fbc404a1661c8f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 20, 2011 at 9:00 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
On Thu, 21 Apr 2011 04:51:07 +0200<br>
<div class=3D"im">Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org"=
>hannes@cmpxchg.org</a>&gt; wrote:<br>
<br>
</div><div class=3D"im">&gt; &gt; If the cgroup is configured to use per cg=
roup background reclaim, a kswapd<br>
&gt; &gt; thread is created which only scans the per-memcg LRU list.<br>
&gt;<br>
&gt; We already have direct reclaim, direct reclaim on behalf of a memcg,<b=
r>
&gt; and global kswapd-reclaim. =A0Please don&#39;t add yet another reclaim=
 path<br>
&gt; that does its own thing and interacts unpredictably with the rest of<b=
r>
&gt; them.<br>
&gt;<br>
&gt; As discussed on LSF, we want to get rid of the global LRU. =A0So the<b=
r>
&gt; goal is to have each reclaim entry end up at the same core part of<br>
&gt; reclaim that round-robin scans a subset of zones from a subset of<br>
&gt; memory control groups.<br>
&gt;<br>
<br>
</div>It&#39;s not related to this set. And I think even if we remove globa=
l LRU,<br>
global-kswapd and memcg-kswapd need to do independent work.<br>
<br>
global-kswapd : works for zone/node balancing and making free pages,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0and compaction. select a memcg vicitm and a=
sk it<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0to reduce memory with regard to gfp_mask. S=
tarts its work<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0when zone/node is unbalanced.<br>
<br>
memcg-kswapd =A0: works for reducing usage of memory, no interests on<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone/nodes. Starts when high/low watermaks =
hits.<br>
<br>
We can share &#39;recalim_memcg_this_zone()&#39; code finally, but it can b=
e<br>
changed when we remove global LRU.<br>
<div class=3D"im"><br>
<br>
&gt; &gt; Two watermarks (&quot;high_wmark&quot;, &quot;low_wmark&quot;) ar=
e added to trigger the<br>
&gt; &gt; background reclaim and stop it. The watermarks are calculated bas=
ed<br>
&gt; &gt; on the cgroup&#39;s limit_in_bytes.<br>
&gt;<br>
&gt; Which brings me to the next issue: making the watermarks configurable.=
<br>
&gt;<br>
&gt; You argued that having them adjustable from userspace is required for<=
br>
&gt; overcommitting the hardlimits and per-memcg kswapd reclaim not kicking=
<br>
&gt; in in case of global memory pressure. =A0But that is only a problem<br=
>
&gt; because global kswapd reclaim is (apart from soft limit reclaim)<br>
&gt; unaware of memory control groups.<br>
&gt;<br>
&gt; I think the much better solution is to make global kswapd memcg aware<=
br>
&gt; (with the above mentioned round-robin reclaim scheduler), compared to<=
br>
&gt; adding new (and final!) kernel ABI to avoid an internal shortcoming.<b=
r>
&gt;<br>
<br>
</div>I don&#39;t think its a good idea to kick kswapd even when free memor=
y is enough.<br>
<br>
If memcg-kswapd implemted, I&#39;d like to add auto-cgroup for memcg-kswapd=
 and<br>
limit its cpu usage because it works even when memory is not in-short.<br><=
/blockquote><div><br></div><div>How are we gonna isolate the memcg-kswapd c=
pu usage under the workqueue model?=A0</div><div><br></div><div>--Ying=A0</=
div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
<br>
Thanks,<br>
-Kame<br>
<br>
<br>
</blockquote></div><br>

--000e0ce008bcb7fbc404a1661c8f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
