Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 78F026B0023
	for <linux-mm@kvack.org>; Fri, 13 May 2011 01:10:36 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p4D5AWmj027500
	for <linux-mm@kvack.org>; Thu, 12 May 2011 22:10:34 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by kpbe13.cbf.corp.google.com with ESMTP id p4D5AUtx016290
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 22:10:31 -0700
Received: by qwf7 with SMTP id 7so1469305qwf.24
        for <linux-mm@kvack.org>; Thu, 12 May 2011 22:10:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110513120318.63ff7d0e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511182844.d128c995.akpm@linux-foundation.org>
	<20110512103503.717f4a96.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511205110.354fa05e.akpm@linux-foundation.org>
	<20110512132237.813a7c7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110512171725.d367980f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110513120318.63ff7d0e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 12 May 2011 22:10:30 -0700
Message-ID: <BANLkTinFesh5cpdk16dWygoWJeH8QU0hTw@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/7] memcg async reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc193a0304a3215355
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>

--000e0ce008bc193a0304a3215355
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 12, 2011 at 8:03 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 12 May 2011 17:17:25 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> > On Thu, 12 May 2011 13:22:37 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > I'll check what codes in vmscan.c or /mm affects memcg and post a
> > required fix in step by step. I think I found some..
> >
>
> After some tests, I doubt that 'automatic' one is unnecessary until
> memcg's dirty_ratio is supported. And as Andrew pointed out,
> total cpu consumption is unchanged and I don't have workloads which
> shows me meaningful speed up.
>

The total cpu consumption is one way to measure the background reclaim,
another thing I would like to measure is a histogram of page fault latency
for a heavy page allocation application. I would expect with background
reclaim, we will get less variation on the page fault latency than w/o it.

Sorry i haven't got chance to run some tests to back it up. I will try to
get some data.


> But I guess...with dirty_ratio, amount of dirty pages in memcg is
> limited and background reclaim can work enough without noise of
> write_page() while applications are throttled by dirty_ratio.
>

Definitely. I have run into the issue while debugging the soft_limit
reclaim. The background reclaim became very inefficient if we have dirty
pages greater than the soft_limit. Talking w/ Greg about it regarding his
per-memcg dirty page limit effort, we should consider setting the dirty
ratio which not allowing the dirty pages greater the reclaim watermarks
(here is the soft_limit).

--Ying


> Hmm, I'll study for a while but it seems better to start active soft limit,
> (or some threshold users can set) first.
>
> Anyway, this work makes me to see vmscan.c carefully and I think I can
> post some patches for fix, tunes.
>
> Thanks,
> -Kame
>
>

--000e0ce008bc193a0304a3215355
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 12, 2011 at 8:03 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
On Thu, 12 May 2011 17:17:25 +0900<br>
<div class=3D"im">KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@j=
p.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt; wrote:<br>
<br>
&gt; On Thu, 12 May 2011 13:22:37 +0900<br>
&gt; KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com=
">kamezawa.hiroyu@jp.fujitsu.com</a>&gt; wrote:<br>
</div><div class=3D"im">&gt; I&#39;ll check what codes in vmscan.c or /mm a=
ffects memcg and post a<br>
&gt; required fix in step by step. I think I found some..<br>
&gt;<br>
<br>
</div>After some tests, I doubt that &#39;automatic&#39; one is unnecessary=
 until<br>
memcg&#39;s dirty_ratio is supported. And as Andrew pointed out,<br>
total cpu consumption is unchanged and I don&#39;t have workloads which<br>
shows me meaningful speed up.<br></blockquote><div><br></div><div>The total=
 cpu consumption is one way to measure the background reclaim, another thin=
g I would like to measure is a histogram of page fault latency</div><div>
for a heavy page allocation application. I would expect with background rec=
laim, we will get less variation on the page fault latency than w/o it.=A0<=
/div><div><br></div><div>Sorry i haven&#39;t got chance to run some tests t=
o back it up. I will try to get some data.</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
But I guess...with dirty_ratio, amount of dirty pages in memcg is<br>
limited and background reclaim can work enough without noise of<br>
write_page() while applications are throttled by dirty_ratio.<br></blockquo=
te><div><br></div><div>Definitely. I have run into the issue while debuggin=
g the soft_limit reclaim. The background reclaim became very inefficient if=
 we have dirty pages greater than the soft_limit. Talking w/ Greg about it =
regarding his per-memcg dirty page limit effort, we should consider setting=
 the dirty ratio which not allowing the dirty pages greater the reclaim wat=
ermarks (here is the soft_limit).</div>
<div><br></div><div>--Ying</div><div>=A0</div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;">
Hmm, I&#39;ll study for a while but it seems better to start active soft li=
mit,<br>
(or some threshold users can set) first.<br>
<br>
Anyway, this work makes me to see vmscan.c carefully and I think I can<br>
post some patches for fix, tunes.<br>
<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--000e0ce008bc193a0304a3215355--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
