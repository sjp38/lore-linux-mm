Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 056E39000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 19:08:46 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p3QN8gGV011243
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:08:42 -0700
Received: from qwb7 (qwb7.prod.google.com [10.241.193.71])
	by kpbe15.cbf.corp.google.com with ESMTP id p3QN8Hdv031725
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:08:41 -0700
Received: by qwb7 with SMTP id 7so606830qwb.26
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:08:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426174754.07a58f22.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
	<20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=aoRhgu3SOKZ8OLRqTew67ciquFg@mail.gmail.com>
	<20110426164341.fb6c80a4.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=sSrrQCMXKJor95Cn-JmiQ=XUAkA@mail.gmail.com>
	<20110426174754.07a58f22.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 16:08:38 -0700
Message-ID: <BANLkTi=PuQPz4tyj4M3bc--asanZd525cA@mail.gmail.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefda8bc61404a1da67dd
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

--0016e64aefda8bc61404a1da67dd
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 26, 2011 at 1:47 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 26 Apr 2011 01:43:17 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Tue, Apr 26, 2011 at 12:43 AM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > > On Tue, 26 Apr 2011 00:19:46 -0700
> > > Ying Han <yinghan@google.com> wrote:
> > >
> > > > On Mon, Apr 25, 2011 at 6:38 PM, KAMEZAWA Hiroyuki
> > > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > On Mon, 25 Apr 2011 15:21:21 -0700
> > > > > Ying Han <yinghan@google.com> wrote:
>
> >
> > > To clarify a bit, my question was meant to account it but not necessary
> to
> > > limit it. We can use existing cpu cgroup to do the cpu limiting, and I
> am
> > >
> > just wondering how to configure it for the memcg kswapd thread.
> >
> >    Let's say in the per-memcg-kswapd model, i can echo the kswapd thread
> pid
> > into the cpu cgroup ( the same set of process of memcg, but in a cpu
> > limiting cgroup instead).  If the kswapd is shared, we might need extra
> work
> > to account the cpu cycles correspondingly.
> >
>
> Hm ? statistics of elapsed_time isn't enough ?
>

I think the stats works for cpu-charging, although we might need to do extra
work to account them for each
work item and also charge them to the cpu cgroup. But it should work for
now.

>
> Now, I think limiting scan/sec interface is more promissing rather than
> time
> or thread controls. It's easier to understand.

Adding monitoring stats is good to start with, like what you have on the
last patch.



> BTW, I think it's better to avoid the watermark reclaim work as kswapd.
> It's confusing because we've talked about global reclaim at LSF.
>

Can you clarify that?

--Ying

>
>
> Thanks,
> -Kame
>
>

--0016e64aefda8bc61404a1da67dd
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 26, 2011 at 1:47 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
On Tue, 26 Apr 2011 01:43:17 -0700<br>
<div class=3D"im">Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yingha=
n@google.com</a>&gt; wrote:<br>
<br>
&gt; On Tue, Apr 26, 2011 at 12:43 AM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Tue, 26 Apr 2011 00:19:46 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; On Mon, Apr 25, 2011 at 6:38 PM, KAMEZAWA Hiroyuki<br>
&gt; &gt; &gt; &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kameza=
wa.hiroyu@jp.fujitsu.com</a>&gt; wrote:<br>
&gt; &gt; &gt; &gt; On Mon, 25 Apr 2011 15:21:21 -0700<br>
&gt; &gt; &gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt; wrote:<br>
<br>
&gt;<br>
</div><div class=3D"im">&gt; &gt; To clarify a bit, my question was meant t=
o account it but not necessary to<br>
&gt; &gt; limit it. We can use existing cpu cgroup to do the cpu limiting, =
and I am<br>
&gt; &gt;<br>
&gt; just wondering how to configure it for the memcg kswapd thread.<br>
&gt;<br>
&gt; =A0 =A0Let&#39;s say in the per-memcg-kswapd model, i can echo the ksw=
apd thread pid<br>
&gt; into the cpu cgroup ( the same set of process of memcg, but in a cpu<b=
r>
&gt; limiting cgroup instead). =A0If the kswapd is shared, we might need ex=
tra work<br>
&gt; to account the cpu cycles correspondingly.<br>
&gt;<br>
<br>
</div>Hm ? statistics of elapsed_time isn&#39;t enough ?<br></blockquote><d=
iv><br></div><div>I think the stats works for cpu-charging, although we mig=
ht need to do extra work to account them for each</div><div>work item and a=
lso charge them to the cpu cgroup. But it should work for now.</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
Now, I think limiting scan/sec interface is more promissing rather than tim=
e<br>
or thread controls. It&#39;s easier to understand.</blockquote><div>Adding =
monitoring stats is good to start with, like what you have on the last patc=
h.</div><div><br></div><div>=A0</div><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

BTW, I think it&#39;s better to avoid the watermark reclaim work as kswapd.=
<br>
It&#39;s confusing because we&#39;ve talked about global reclaim at LSF.<br=
></blockquote><div><br></div><div>Can you clarify that?</div><div><br></div=
><div>--Ying=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

<br>
<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--0016e64aefda8bc61404a1da67dd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
