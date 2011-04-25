Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E3B378D003B
	for <linux-mm@kvack.org>; Sun, 24 Apr 2011 22:08:23 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p3P28LgT012980
	for <linux-mm@kvack.org>; Sun, 24 Apr 2011 19:08:21 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by kpbe14.cbf.corp.google.com with ESMTP id p3P28IcJ007196
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 24 Apr 2011 19:08:20 -0700
Received: by qyk2 with SMTP id 2so655908qyk.14
        for <linux-mm@kvack.org>; Sun, 24 Apr 2011 19:08:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425082642.034a5f64.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-5-git-send-email-yinghan@google.com>
	<20110422133643.6a36d838.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinkJC2-HiGtxgTTo8RvRjZqYuq2pA@mail.gmail.com>
	<20110422140023.949e5737.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim91aHXjqfukn6rJxK0SDSSG2wrrg@mail.gmail.com>
	<20110422145943.a8f5a4ef.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikRvjNR94tUf2p9UPQFGLUYp41Twg@mail.gmail.com>
	<20110422164622.a8350bc5.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikfsLB8kTFZe+qj_jK=psgtFMfBMA@mail.gmail.com>
	<20110425082642.034a5f64.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 24 Apr 2011 19:08:17 -0700
Message-ID: <BANLkTimGBHW7P=M6VJdrCs2FL_DoLY86fA@mail.gmail.com>
Subject: Re: [PATCH V7 4/9] Add memcg kswapd thread pool
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc50ff2504a1b4aef9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0ce008bc50ff2504a1b4aef9
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Apr 24, 2011 at 4:26 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 22 Apr 2011 00:59:26 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Fri, Apr 22, 2011 at 12:46 AM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> > > From this, I feel I need to use unbound workqueue. BTW, with patches
> for
> > > current thread pool model, I think starvation problem by dirty pages
> > > cannot be seen.
> > > Anyway, I'll give a try.
> > >
> >
> > Then do you suggest me to wait for your patch for my next post?
> >
>
> I used most of weekend for background reclaim on workqueue and I changed
> many
> things based on your patch (but dropped most of kswapd
> descriptor...patches.)
>
> Thank you for the heads up. Although I am still having concerns on the
workqueue approach, but
thank you for your time to give a try.

One of my concerns is still the debug-ability and I am not being convinced
the resource consumption is a killing issue for the per-memcg
kswapd thread. Anyway, looking to see your change.

--Ying



> I'll post it today after some tests on machines in my office. It worked
> well
> on my laptop.
>
> Thanks,
> -Kame
>
>

--000e0ce008bc50ff2504a1b4aef9
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sun, Apr 24, 2011 at 4:26 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
On Fri, 22 Apr 2011 00:59:26 -0700<br>
<div class=3D"im">Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yingha=
n@google.com</a>&gt; wrote:<br>
<br>
</div><div class=3D"im">&gt; On Fri, Apr 22, 2011 at 12:46 AM, KAMEZAWA Hir=
oyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
<br>
</div><div class=3D"im">&gt; &gt; From this, I feel I need to use unbound w=
orkqueue. BTW, with patches for<br>
&gt; &gt; current thread pool model, I think starvation problem by dirty pa=
ges<br>
&gt; &gt; cannot be seen.<br>
&gt; &gt; Anyway, I&#39;ll give a try.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Then do you suggest me to wait for your patch for my next post?<br>
&gt;<br>
<br>
</div>I used most of weekend for background reclaim on workqueue and I chan=
ged many<br>
things based on your patch (but dropped most of kswapd descriptor...patches=
.)<br>
<br></blockquote><div>Thank you for the heads up. Although I am still havin=
g concerns on the workqueue approach, but=A0</div><div>thank you for your t=
ime to give a try.=A0</div><div><br></div><div>One of my concerns is still =
the=A0debug-ability and I am not being=A0convinced the resource consumption=
 is a killing issue for the per-memcg</div>
<div>kswapd thread. Anyway, looking to see your change.</div><div><br></div=
><div>--Ying =A0</div><div><br></div><div>=A0</div><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex;">

I&#39;ll post it today after some tests on machines in my office. It worked=
 well<br>
on my laptop.<br>
<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--000e0ce008bc50ff2504a1b4aef9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
