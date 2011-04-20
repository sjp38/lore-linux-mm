Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B4A858D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:51:20 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p3K0pEQw000633
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 17:51:14 -0700
Received: from qwi2 (qwi2.prod.google.com [10.241.195.2])
	by wpaz21.hot.corp.google.com with ESMTP id p3K0osoY012533
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 17:51:13 -0700
Received: by qwi2 with SMTP id 2so166133qwi.22
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 17:51:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110420092003.45EB.A69D9226@jp.fujitsu.com>
References: <1303235496-3060-1-git-send-email-yinghan@google.com>
	<20110420092003.45EB.A69D9226@jp.fujitsu.com>
Date: Tue, 19 Apr 2011 17:51:12 -0700
Message-ID: <BANLkTikJfOevEUqivf8b1XkL1vTmL6RBEQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] pass the scan_control into shrinkers
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00248c6a84ca73547804a14f0509
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--00248c6a84ca73547804a14f0509
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 19, 2011 at 5:20 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> > This patch changes the shrink_slab and shrinker APIs by consolidating
> existing
> > parameters into scan_control struct. This simplifies any further attempts
> to
> > pass extra info to the shrinker. Instead of modifying all the shrinker
> files
> > each time, we just need to extend the scan_control struct.
> >
>
> Ugh. No, please no.
> Current scan_control has a lot of vmscan internal information. Please
> export only you need one, not all.
>
> Otherwise, we can't change any vmscan code while any shrinker are using it.
>

So, are you suggesting maybe add another struct for this purpose?

--Ying

--00248c6a84ca73547804a14f0509
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 19, 2011 at 5:20 PM, KOSAKI =
Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu=
.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex;">
<div class=3D"im">&gt; This patch changes the shrink_slab and shrinker APIs=
 by consolidating existing<br>
&gt; parameters into scan_control struct. This simplifies any further attem=
pts to<br>
&gt; pass extra info to the shrinker. Instead of modifying all the shrinker=
 files<br>
&gt; each time, we just need to extend the scan_control struct.<br>
&gt;<br>
<br>
</div>Ugh. No, please no.<br>
Current scan_control has a lot of vmscan internal information. Please<br>
export only you need one, not all.<br>
<br>
Otherwise, we can&#39;t change any vmscan code while any shrinker are using=
 it.<br></blockquote><div><br></div><div>So, are you suggesting maybe add a=
nother struct for this purpose?</div><div><br></div><div>--Ying=A0</div>
</div><br>

--00248c6a84ca73547804a14f0509--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
