Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B84E36B0023
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 04:42:49 -0400 (EDT)
Received: by ggnh4 with SMTP id h4so4499222ggn.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 01:42:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110272307110.14619@router.home>
References: <1319384922-29632-1-git-send-email-gilad@benyossef.com>
	<1319384922-29632-5-git-send-email-gilad@benyossef.com>
	<alpine.DEB.2.00.1110272307110.14619@router.home>
Date: Fri, 28 Oct 2011 10:42:47 +0200
Message-ID: <CAOtvUMdCecUuue+hzue3CY79N_eYS6fDiRXp6BVkfNYfrZoBVA@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] mm: Only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: multipart/alternative; boundary=bcaec52c5ea9a02f7d04b057df44
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

--bcaec52c5ea9a02f7d04b057df44
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Oct 28, 2011 at 6:10 AM, Christoph Lameter <cl@gentwo.org> wrote:

> On Sun, 23 Oct 2011, Gilad Ben-Yossef wrote:
>
> > +/* Which CPUs have per cpu pages  */
> > +cpumask_var_t cpus_with_pcp;
> > +static DEFINE_PER_CPU(unsigned long, total_cpu_pcp_count);
>
> This increases the cache footprint of a hot vm path. Is it possible to do
> the same than what you did for slub? Run a loop over all zones when
> draining to check for remaining pcp pages and build the set of cpus
> needing IPIs temporarily while draining?
>
>
Sounds like a good idea. I will give it a shot.

Thanks,
Gilad



-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"I've seen things you people wouldn't believe. Goto statements used to
implement co-routines. I watched C structures being stored in registers. All
those moments will be lost in time... like tears in rain... Time to die. "

--bcaec52c5ea9a02f7d04b057df44
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br>On Fri, Oct 28, 2011 at 6:10 AM, Christoph Lameter <sp=
an dir=3D"ltr">&lt;<a href=3D"mailto:cl@gentwo.org">cl@gentwo.org</a>&gt;</=
span> wrote:<br><div class=3D"gmail_quote"><blockquote class=3D"gmail_quote=
" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Sun, 23 Oct <a href=3D"tel:2011" value=3D"+9722011">20=
11</a>, Gilad Ben-Yossef wrote:<br>
<br>
&gt; +/* Which CPUs have per cpu pages =A0*/<br>
&gt; +cpumask_var_t cpus_with_pcp;<br>
&gt; +static DEFINE_PER_CPU(unsigned long, total_cpu_pcp_count);<br>
<br>
</div>This increases the cache footprint of a hot vm path. Is it possible t=
o do<br>
the same than what you did for slub? Run a loop over all zones when<br>
draining to check for remaining pcp pages and build the set of cpus<br>
needing IPIs temporarily while draining?<br>
<br></blockquote><div><br></div><div>Sounds like a good idea. I will give i=
t a shot.</div><div><br></div><div>Thanks,</div><div>Gilad=A0</div></div><b=
r><br clear=3D"all"><div><br></div>-- <br>Gilad Ben-Yossef<br>Chief Coffee =
Drinker<br>
<a href=3D"mailto:gilad@benyossef.com" target=3D"_blank">gilad@benyossef.co=
m</a><br>Israel Cell: +972-52-8260388<br>US Cell: +1-973-8260388<br><a href=
=3D"http://benyossef.com" target=3D"_blank">http://benyossef.com</a><br><br=
>&quot;I&#39;ve seen things you people wouldn&#39;t believe. Goto statement=
s used to implement co-routines. I watched C structures being stored in reg=
isters. All those moments will be lost in time... like tears in rain... Tim=
e to die. &quot;<br>
<br>
</div>

--bcaec52c5ea9a02f7d04b057df44--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
