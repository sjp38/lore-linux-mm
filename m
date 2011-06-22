Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D4DB0900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 12:31:41 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p5MGVapY024628
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:31:36 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by hpaq3.eem.corp.google.com with ESMTP id p5MGRh29031534
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:31:35 -0700
Received: by qyk10 with SMTP id 10so2856009qyk.4
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:31:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110622152216.GG14343@tiehlicka.suse.cz>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125222.71bcdff3.kamezawa.hiroyu@jp.fujitsu.com>
	<20110622152216.GG14343@tiehlicka.suse.cz>
Date: Wed, 22 Jun 2011 09:31:32 -0700
Message-ID: <BANLkTikKMHB0uaOvCyAwjtedRcRr1vJ4VAiVpiQO-29MS0ZPog@mail.gmail.com>
Subject: Re: [PATCH 2/7] export memory cgroup's swappines by mem_cgroup_swappiness()
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefda53506004a64f807a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

--0016e64aefda53506004a64f807a
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Jun 22, 2011 at 8:22 AM, Michal Hocko <mhocko@suse.cz> wrote:
>
> On Thu 16-06-11 12:52:22, KAMEZAWA Hiroyuki wrote:
> > From 6f9c40172947fb92ab0ea6f7d73d577473879636 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Wed, 15 Jun 2011 12:06:31 +0900
> > Subject: [PATCH 2/7] export memory cgroup's swappines by
mem_cgroup_swappiness()
> >
> > Each memory cgroup has 'swappiness' value and it can be accessed by
> > get_swappiness(memcg). The major user is try_to_free_mem_cgroup_pages()
> > and swappiness is passed by argument.
> >
> > It's now static function but some planned updates will need to
> > get swappiness from files other than memcontrol.c
> > This patch exports get_swappiness() as mem_cgroup_swappiness().
> > By this, we can remove the argument of swapiness from try_to_fre...
> >
> > I think this makes sense because passed swapiness is always from memory
> > cgroup passed as an argument and this duplication of argument is
> > not very good.
>
> Yes makes sense and it makes it more looking like a global reclaim.
>
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
 Acked-by: Ying Han <yinghan@google.com>

--Ying
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic

--0016e64aefda53506004a64f807a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br>On Wed, Jun 22, 2011 at 8:22 AM, Michal Hocko &lt;<a href=3D"mailto=
:mhocko@suse.cz">mhocko@suse.cz</a>&gt; wrote:<br>&gt;<br>&gt; On Thu 16-06=
-11 12:52:22, KAMEZAWA Hiroyuki wrote:<br>&gt; &gt; From 6f9c40172947fb92ab=
0ea6f7d73d577473879636 Mon Sep 17 00:00:00 2001<br>
&gt; &gt; From: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.=
fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>&gt; &gt; Date: Wed,=
 15 Jun 2011 12:06:31 +0900<br>&gt; &gt; Subject: [PATCH 2/7] export memory=
 cgroup&#39;s swappines by mem_cgroup_swappiness()<br>
&gt; &gt;<br>&gt; &gt; Each memory cgroup has &#39;swappiness&#39; value an=
d it can be accessed by<br>&gt; &gt; get_swappiness(memcg). The major user =
is try_to_free_mem_cgroup_pages()<br>&gt; &gt; and swappiness is passed by =
argument.<br>
&gt; &gt;<br>&gt; &gt; It&#39;s now static function but some planned update=
s will need to<br>&gt; &gt; get swappiness from files other than memcontrol=
.c<br>&gt; &gt; This patch exports get_swappiness() as mem_cgroup_swappines=
s().<br>
&gt; &gt; By this, we can remove the argument of swapiness from try_to_fre.=
..<br>&gt; &gt;<br>&gt; &gt; I think this makes sense because passed swapin=
ess is always from memory<br>&gt; &gt; cgroup passed as an argument and thi=
s duplication of argument is<br>
&gt; &gt; not very good.<br>&gt;<br>&gt; Yes makes sense and it makes it mo=
re looking like a global reclaim.<br>&gt;<br>&gt; &gt;<br>&gt; &gt; Signed-=
off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.=
com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt;<br>&gt; Reviewed-by: Michal Hocko &lt;<a href=3D"mailto:mhocko@suse.cz=
">mhocko@suse.cz</a>&gt;<br>&gt;<br>=A0Acked-by:=A0Ying=A0Han=A0&lt;<a href=
=3D"mailto:yinghan@google.com">yinghan@google.com</a>&gt;<div><br></div><di=
v>--Ying<br>
&gt;<br>&gt; --<br>&gt; Michal Hocko<br>&gt; SUSE Labs<br>&gt; SUSE LINUX s=
.r.o.<br>&gt; Lihovarska 1060/12<br>&gt; 190 00 Praha 9<br>&gt; Czech Repub=
lic<br><br></div>

--0016e64aefda53506004a64f807a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
