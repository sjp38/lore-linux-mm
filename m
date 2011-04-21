Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC8A8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 03:12:22 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p3L7CIl2021728
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:12:18 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by hpaq2.eem.corp.google.com with ESMTP id p3L7CCI3031991
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:12:17 -0700
Received: by qyk2 with SMTP id 2so3278452qyk.14
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:12:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421160152.5bc1c1b1.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421124836.16769ffc.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimFASy=jsEk=1rZSH2o386-gDgvxA@mail.gmail.com>
	<20110421153804.6da5c5ea.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=Y7SfFv=LMmaspyTXXSHrO5LJaiQ@mail.gmail.com>
	<20110421160152.5bc1c1b1.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 21 Apr 2011 00:12:11 -0700
Message-ID: <BANLkTim3CUxnxg6ERyLL8pxvJPyi8Jti9g@mail.gmail.com>
Subject: Re: [PATCH 2/3] weight for memcg background reclaim (Was Re: [PATCH
 V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa8cc9b1304a1687575
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--002354470aa8cc9b1304a1687575
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 21, 2011 at 12:01 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 20 Apr 2011 23:59:52 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Wed, Apr 20, 2011 at 11:38 PM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > > On Wed, 20 Apr 2011 23:11:42 -0700
> > > Ying Han <yinghan@google.com> wrote:
> > >
> > > > On Wed, Apr 20, 2011 at 8:48 PM, KAMEZAWA Hiroyuki <
> > > > kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> > n general, memcg-kswapd can reduce memory down to high watermak only when
> > > the system is not busy. So, this logic tries to remove more memory from
> busy
> > > cgroup to reduce 'hit limit'.
> > >
> >
> > So, the "busy cgroup" here means the memcg has higher (usage - low)?
> >
>
>   high < usage < low < limit
>
> Yes, if background reclaim wins, usage - high decreases.
> If tasks on cgroup uses more memory than reclaim, usage - high increases
> even
> if background reclaim runs. So, if usage-high is large, cgroup is busy.
>
> Yes, I think I understand the (usage - high) in the calculation, but not
the (low - high).

--Ying

>
>
> Thanks,
> -Kame
>
>

--002354470aa8cc9b1304a1687575
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 21, 2011 at 12:01 AM, KAMEZA=
WA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fuji=
tsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">
On Wed, 20 Apr 2011 23:59:52 -0700<br>
<div class=3D"im">Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yingha=
n@google.com</a>&gt; wrote:<br>
<br>
&gt; On Wed, Apr 20, 2011 at 11:38 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Wed, 20 Apr 2011 23:11:42 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; On Wed, Apr 20, 2011 at 8:48 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; &gt; &gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.h=
iroyu@jp.fujitsu.com</a>&gt; wrote:<br>
<br>
</div><div class=3D"im">&gt; n general, memcg-kswapd can reduce memory down=
 to high watermak only when<br>
&gt; &gt; the system is not busy. So, this logic tries to remove more memor=
y from busy<br>
&gt; &gt; cgroup to reduce &#39;hit limit&#39;.<br>
&gt; &gt;<br>
&gt;<br>
&gt; So, the &quot;busy cgroup&quot; here means the memcg has higher (usage=
 - low)?<br>
&gt;<br>
<br>
</div> =A0high &lt; usage &lt; low &lt; limit<br>
<br>
Yes, if background reclaim wins, usage - high decreases.<br>
If tasks on cgroup uses more memory than reclaim, usage - high increases ev=
en<br>
if background reclaim runs. So, if usage-high is large, cgroup is busy.<br>
<br></blockquote><div>Yes, I think I understand the (usage - high) in the c=
alculation, but not the (low - high).</div><div><br></div><div>--Ying</div>=
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">

<br>
<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--002354470aa8cc9b1304a1687575--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
