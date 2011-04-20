Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 103718D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 21:03:59 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p3K13uJ4010289
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 18:03:56 -0700
Received: from qwa26 (qwa26.prod.google.com [10.241.193.26])
	by wpaz37.hot.corp.google.com with ESMTP id p3K13sCT019803
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 18:03:55 -0700
Received: by qwa26 with SMTP id 26so136043qwa.28
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 18:03:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110420095429.45FD.A69D9226@jp.fujitsu.com>
References: <20110420092003.45EB.A69D9226@jp.fujitsu.com>
	<BANLkTikJfOevEUqivf8b1XkL1vTmL6RBEQ@mail.gmail.com>
	<20110420095429.45FD.A69D9226@jp.fujitsu.com>
Date: Tue, 19 Apr 2011 18:03:54 -0700
Message-ID: <BANLkTimWMr9Fp=cFF3q2Q5_pyrUVnFsS2w@mail.gmail.com>
Subject: Re: [PATCH 0/3] pass the scan_control into shrinkers
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee0dd080f04a14f324a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cd68ee0dd080f04a14f324a
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 19, 2011 at 5:54 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Tue, Apr 19, 2011 at 5:20 PM, KOSAKI Motohiro <
> > kosaki.motohiro@jp.fujitsu.com> wrote:
> >
> > > > This patch changes the shrink_slab and shrinker APIs by consolidating
> > > existing
> > > > parameters into scan_control struct. This simplifies any further
> attempts
> > > to
> > > > pass extra info to the shrinker. Instead of modifying all the
> shrinker
> > > files
> > > > each time, we just need to extend the scan_control struct.
> > > >
> > >
> > > Ugh. No, please no.
> > > Current scan_control has a lot of vmscan internal information. Please
> > > export only you need one, not all.
> > >
> > > Otherwise, we can't change any vmscan code while any shrinker are using
> it.
> > >
> >
> > So, are you suggesting maybe add another struct for this purpose?
>
> Yes. And please explain which member do you need.
>

For now, I added the "nr_slab_to_reclaim" and also consolidate the
gfp_mask. More importantly this makes any further change (pass stuff from
reclaim to the shrinkers) easier w/o modifying each file of the shrinker.

So make it into a new struct sounds reasonable to me. How about something
called "slab_control".

--Ying

--000e0cd68ee0dd080f04a14f324a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 19, 2011 at 5:54 PM, KOSAKI =
Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu=
.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex;">
<div><div></div><div class=3D"h5">&gt; On Tue, Apr 19, 2011 at 5:20 PM, KOS=
AKI Motohiro &lt;<br>
&gt; <a href=3D"mailto:kosaki.motohiro@jp.fujitsu.com">kosaki.motohiro@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; &gt; This patch changes the shrink_slab and shrinker APIs by cons=
olidating<br>
&gt; &gt; existing<br>
&gt; &gt; &gt; parameters into scan_control struct. This simplifies any fur=
ther attempts<br>
&gt; &gt; to<br>
&gt; &gt; &gt; pass extra info to the shrinker. Instead of modifying all th=
e shrinker<br>
&gt; &gt; files<br>
&gt; &gt; &gt; each time, we just need to extend the scan_control struct.<b=
r>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Ugh. No, please no.<br>
&gt; &gt; Current scan_control has a lot of vmscan internal information. Pl=
ease<br>
&gt; &gt; export only you need one, not all.<br>
&gt; &gt;<br>
&gt; &gt; Otherwise, we can&#39;t change any vmscan code while any shrinker=
 are using it.<br>
&gt; &gt;<br>
&gt;<br>
&gt; So, are you suggesting maybe add another struct for this purpose?<br>
<br>
</div></div>Yes. And please explain which member do you need.<br></blockquo=
te><div><br></div><div>For now, I added the &quot;nr_slab_to_reclaim&quot; =
and also consolidate the gfp_mask.=A0More importantly this makes any furthe=
r change (pass stuff from reclaim to the shrinkers) easier w/o modifying ea=
ch file of the shrinker.=A0</div>
<div><br></div><div>So make it into a new struct sounds reasonable to me. H=
ow about something called &quot;slab_control&quot;.</div><div><br></div><di=
v>--Ying</div></div><br>

--000e0cd68ee0dd080f04a14f324a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
