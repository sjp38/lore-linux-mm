Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 3FB686B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 04:17:17 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id dn14so3784627obc.12
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 01:17:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130804080954.GB24005@dhcp22.suse.cz>
References: <1375593061-11350-1-git-send-email-manjunath.goudar@linaro.org>
	<20130804080954.GB24005@dhcp22.suse.cz>
Date: Sun, 4 Aug 2013 13:47:16 +0530
Message-ID: <CAJFYCKHWk4YTR9WyB9gxYsa8iUfx27SWQV72cAiHGGP6qHkO2w@mail.gmail.com>
Subject: Re: [PATCH] MM: Make Contiguous Memory Allocator depends on MMU
From: Manjunath Goudar <manjunath.goudar@linaro.org>
Content-Type: multipart/alternative; boundary=90e6ba21219bd81fc104e31ad141
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-arm-kernel@lists.infradead.org, patches@linaro.org, arnd@linaro.org, dsaxena@linaro.org, linaro-kernel@lists.linaro.org, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--90e6ba21219bd81fc104e31ad141
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 4 August 2013 13:39, Michal Hocko <mhocko@suse.cz> wrote:

> On Sun 04-08-13 10:41:01, Manjunath Goudar wrote:
> > s patch adds a Kconfig dependency on an MMU being available before
> > CMA can be enabled.  Without this patch, CMA can be enabled on an
> > MMU-less system which can lead to issues. This was discovered during
> > randconfig testing, in which CMA was enabled w/o MMU being enabled,
> > leading to the following error:
> >
> >  CC      mm/migrate.o
> > mm/migrate.c: In function =91remove_migration_pte=92:
> > mm/migrate.c:134:3: error: implicit declaration of function
> =91pmd_trans_huge=92
> > [-Werror=3Dimplicit-function-declaration]
> >    if (pmd_trans_huge(*pmd))
> >    ^
> > mm/migrate.c:137:3: error: implicit declaration of function
> =91pte_offset_map=92
> > [-Werror=3Dimplicit-function-declaration]
> >    ptep =3D pte_offset_map(pmd, addr);
>
> This is a migration code but you are updating configuration for CMA
> which doesn't make much sense to me.
> I guess you wanted to disable migration for CMA instead?
>

 Yes you are right.Already Chen Gang has written similar patch.

>
> > Signed-off-by: Manjunath Goudar <manjunath.goudar@linaro.org>
> > Acked-by: Arnd Bergmann <arnd@linaro.org>
> > Cc: Deepak Saxena <dsaxena@linaro.org>
> > Cc: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
> > Cc: Hirokazu Takahashi <taka@valinux.co.jp>
> > Cc: Dave Hansen <haveblue@us.ibm.com>
> > Cc: linux-mm@kvack.org
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Cc: Balbir Singh <bsingharora@gmail.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/Kconfig |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 256bfd0..ad6b98e 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -522,7 +522,7 @@ config MEM_SOFT_DIRTY
> >
> >  config CMA
> >       bool "Contiguous Memory Allocator"
> > -     depends on HAVE_MEMBLOCK
> > +     depends on MMU && HAVE_MEMBLOCK
> >       select MIGRATION
> >       select MEMORY_ISOLATION
> >       help
> > --
> > 1.7.9.5
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Michal Hocko
> SUSE Labs
>

Thanks
Manjunath Goudar

--90e6ba21219bd81fc104e31ad141
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On 4 August 2013 13:39, Michal Hocko <sp=
an dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@suse.cz" target=3D"_blank">mhoc=
ko@suse.cz</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D"im">On Sun 04-08-13 10:41:01, Manjunath Goudar wrote:<br>
&gt; s patch adds a Kconfig dependency on an MMU being available before<br>
&gt; CMA can be enabled. =A0Without this patch, CMA can be enabled on an<br=
>
&gt; MMU-less system which can lead to issues. This was discovered during<b=
r>
&gt; randconfig testing, in which CMA was enabled w/o MMU being enabled,<br=
>
&gt; leading to the following error:<br>
&gt;<br>
&gt; =A0CC =A0 =A0 =A0mm/migrate.o<br>
&gt; mm/migrate.c: In function =91remove_migration_pte=92:<br>
&gt; mm/migrate.c:134:3: error: implicit declaration of function =91pmd_tra=
ns_huge=92<br>
&gt; [-Werror=3Dimplicit-function-declaration]<br>
&gt; =A0 =A0if (pmd_trans_huge(*pmd))<br>
&gt; =A0 =A0^<br>
&gt; mm/migrate.c:137:3: error: implicit declaration of function =91pte_off=
set_map=92<br>
&gt; [-Werror=3Dimplicit-function-declaration]<br>
&gt; =A0 =A0ptep =3D pte_offset_map(pmd, addr);<br>
<br>
</div>This is a migration code but you are updating configuration for CMA<b=
r>
which doesn&#39;t make much sense to me.<br>
I guess you wanted to disable migration for CMA instead?<br></blockquote><d=
iv><br></div><div>=A0Yes you are right.Already Chen Gang has written simila=
r=A0patch.<span style=3D"font-family:&#39;courier new&#39;,courier,monospac=
e;font-size:16px;font-weight:600">=A0</span></div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt; Signed-off-by: Manjunath Goudar &lt;<a href=3D"mailto:manjunath.goudar=
@linaro.org">manjunath.goudar@linaro.org</a>&gt;<br>
&gt; Acked-by: Arnd Bergmann &lt;<a href=3D"mailto:arnd@linaro.org">arnd@li=
naro.org</a>&gt;<br>
&gt; Cc: Deepak Saxena &lt;<a href=3D"mailto:dsaxena@linaro.org">dsaxena@li=
naro.org</a>&gt;<br>
&gt; Cc: IWAMOTO Toshihiro &lt;<a href=3D"mailto:iwamoto@valinux.co.jp">iwa=
moto@valinux.co.jp</a>&gt;<br>
&gt; Cc: Hirokazu Takahashi &lt;<a href=3D"mailto:taka@valinux.co.jp">taka@=
valinux.co.jp</a>&gt;<br>
&gt; Cc: Dave Hansen &lt;<a href=3D"mailto:haveblue@us.ibm.com">haveblue@us=
.ibm.com</a>&gt;<br>
&gt; Cc: <a href=3D"mailto:linux-mm@kvack.org">linux-mm@kvack.org</a><br>
&gt; Cc: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes@c=
mpxchg.org</a>&gt;<br>
&gt; Cc: Michal Hocko &lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.cz<=
/a>&gt;<br>
&gt; Cc: Balbir Singh &lt;<a href=3D"mailto:bsingharora@gmail.com">bsinghar=
ora@gmail.com</a>&gt;<br>
&gt; Cc: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu=
.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0mm/Kconfig | =A0 =A02 +-<br>
&gt; =A01 file changed, 1 insertion(+), 1 deletion(-)<br>
&gt;<br>
&gt; diff --git a/mm/Kconfig b/mm/Kconfig<br>
&gt; index 256bfd0..ad6b98e 100644<br>
&gt; --- a/mm/Kconfig<br>
&gt; +++ b/mm/Kconfig<br>
&gt; @@ -522,7 +522,7 @@ config MEM_SOFT_DIRTY<br>
&gt;<br>
&gt; =A0config CMA<br>
&gt; =A0 =A0 =A0 bool &quot;Contiguous Memory Allocator&quot;<br>
&gt; - =A0 =A0 depends on HAVE_MEMBLOCK<br>
&gt; + =A0 =A0 depends on MMU &amp;&amp; HAVE_MEMBLOCK<br>
&gt; =A0 =A0 =A0 select MIGRATION<br>
&gt; =A0 =A0 =A0 select MEMORY_ISOLATION<br>
&gt; =A0 =A0 =A0 help<br>
&gt; --<br>
&gt; 1.7.9.5<br>
&gt;<br>
</div></div><div class=3D"HOEnZb"><div class=3D"h5">&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>. =A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www=
.linux-mm.org/</a> .<br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
<br>
</div></div><span class=3D"HOEnZb"><font color=3D"#888888">--<br>
Michal Hocko<br>
SUSE Labs<br>
</font></span></blockquote></div><div><br></div>Thanks<div>Manjunath Goudar=
</div>

--90e6ba21219bd81fc104e31ad141--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
