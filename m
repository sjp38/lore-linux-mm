Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C661900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:46:24 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p3J3kF3v001632
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 20:46:20 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by wpaz21.hot.corp.google.com with ESMTP id p3J3kEvO011265
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 20:46:14 -0700
Received: by qyk2 with SMTP id 2so3976466qyk.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 20:46:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=CeBGF63gDj=jvWyXs3OjjkTsEpg@mail.gmail.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<20110415094040.GC8828@tiehlicka.suse.cz>
	<BANLkTimJ2hhuP-Rph+2DtHG-F_gHXg4CWg@mail.gmail.com>
	<20110418091351.GC8925@tiehlicka.suse.cz>
	<BANLkTimkPasX8AA=HCOgVeSyPBSivz8pMg@mail.gmail.com>
	<20110418184240.GA11653@tiehlicka.suse.cz>
	<BANLkTi=HotRcWiRc4qa1aN+NJ4H5vfCWWA@mail.gmail.com>
	<BANLkTi=CeBGF63gDj=jvWyXs3OjjkTsEpg@mail.gmail.com>
Date: Mon, 18 Apr 2011 20:46:14 -0700
Message-ID: <BANLkTimyHimoqjmkLePcuzq41+in0aJBAw@mail.gmail.com>
Subject: Re: [PATCH V4 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0023544706748c1c4a04a13d5971
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

--0023544706748c1c4a04a13d5971
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 18, 2011 at 7:48 PM, Zhu Yanhai <zhu.yanhai@gmail.com> wrote:

> Hi,
>
> 2011/4/19 Ying Han <yinghan@google.com>:
> >
> > that is true.  I adopt the initial comment from Mel where we keep the
> same
> > logic of triggering and stopping kswapd with low/high_wmarks and also
> > comparing the usage_in_bytes to the wmarks. Either way is confusing and
> > guess we just need to document it well.
>
> IMO another thing need to document well is that a user must setup
> high_wmark_distance before setup low_wmark_distance to to make it
> start work, and zero  low_wmark_distance before zero
> high_wmark_distance to stop it. Otherwise it won't pass the sanity
> check, which is not quite obvious.
>

yes. will add into the document.

--Ying

>
> Thanks,
> Zhu Yanhai
>
> > --Ying
> >>
> >> --
> >> Michal Hocko
> >> SUSE Labs
> >> SUSE LINUX s.r.o.
> >> Lihovarska 1060/12
> >> 190 00 Praha 9
> >> Czech Republic
> >
> >
>

--0023544706748c1c4a04a13d5971
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 18, 2011 at 7:48 PM, Zhu Yan=
hai <span dir=3D"ltr">&lt;<a href=3D"mailto:zhu.yanhai@gmail.com">zhu.yanha=
i@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Hi,<br>
<br>
2011/4/19 Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt;:<br>
<div class=3D"im">&gt;<br>
&gt; that is true. =A0I adopt the initial comment from Mel where we keep th=
e same<br>
&gt; logic of triggering and stopping kswapd with low/high_wmarks and also<=
br>
&gt; comparing the usage_in_bytes to the wmarks.=A0Either way is confusing =
and<br>
&gt; guess we just need to document it well.<br>
<br>
</div>IMO another thing need to document well is that a user must setup<br>
high_wmark_distance before setup low_wmark_distance to to make it<br>
start work, and zero =A0low_wmark_distance before zero<br>
high_wmark_distance to stop it. Otherwise it won&#39;t pass the sanity<br>
check, which is not quite obvious.<br></blockquote><div><br></div><div>yes.=
 will add into the document.</div><div><br></div><div>--Ying=A0</div><block=
quote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc=
 solid;padding-left:1ex;">

<br>
Thanks,<br>
<font color=3D"#888888">Zhu Yanhai<br>
</font><div><div></div><div class=3D"h5"><br>
&gt; --Ying<br>
&gt;&gt;<br>
&gt;&gt; --<br>
&gt;&gt; Michal Hocko<br>
&gt;&gt; SUSE Labs<br>
&gt;&gt; SUSE LINUX s.r.o.<br>
&gt;&gt; Lihovarska 1060/12<br>
&gt;&gt; 190 00 Praha 9<br>
&gt;&gt; Czech Republic<br>
&gt;<br>
&gt;<br>
</div></div></blockquote></div><br>

--0023544706748c1c4a04a13d5971--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
