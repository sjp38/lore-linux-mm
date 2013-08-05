Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id A1E2A6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 04:37:42 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id xn12so4955545obc.20
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 01:37:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130805073239.GC10146@dhcp22.suse.cz>
References: <1375593061-11350-1-git-send-email-manjunath.goudar@linaro.org>
	<51fe08c6.87ef440a.10fc.1786SMTPIN_ADDED_BROKEN@mx.google.com>
	<CAJFYCKEhJtG1x1PaiwpwOADxthXRSh0pQsE3uYWO2i4xnHGvYQ@mail.gmail.com>
	<20130805073239.GC10146@dhcp22.suse.cz>
Date: Mon, 5 Aug 2013 14:07:41 +0530
Message-ID: <CAJFYCKGZte3FER8MNRX3T_c=jgYbCb+WEWtdz4wSPa9XZ8huGg@mail.gmail.com>
Subject: Re: [PATCH] MM: Make Contiguous Memory Allocator depends on MMU
From: Manjunath Goudar <manjunath.goudar@linaro.org>
Content-Type: multipart/alternative; boundary=90e6ba21219bbae0b904e32f3815
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, patches@linaro.org, arnd@linaro.org, dsaxena@linaro.org, linaro-kernel@lists.linaro.org, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, hyojun.im@lge.com, Nataraja KM/LGSIA CSP-4 <nataraja.km@lge.com>

--90e6ba21219bbae0b904e32f3815
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 5 August 2013 13:02, Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 05-08-13 10:10:08, Manjunath Goudar wrote:
> > On 4 August 2013 13:24, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> >
> > > On Sun, Aug 04, 2013 at 10:41:01AM +0530, Manjunath Goudar wrote:
> > > >s patch adds a Kconfig dependency on an MMU being available before
> > > >CMA can be enabled.  Without this patch, CMA can be enabled on an
> > > >MMU-less system which can lead to issues. This was discovered during
> > > >randconfig testing, in which CMA was enabled w/o MMU being enabled,
> > > >leading to the following error:
> > > >
> > > > CC      mm/migrate.o
> > > >mm/migrate.c: In function =91remove_migration_pte=92:
> > > >mm/migrate.c:134:3: error: implicit declaration of function
> > > =91pmd_trans_huge=92
> > > >[-Werror=3Dimplicit-function-declaration]
> > > >   if (pmd_trans_huge(*pmd))
> > > >   ^
> > > >mm/migrate.c:137:3: error: implicit declaration of function
> > > =91pte_offset_map=92
> > > >[-Werror=3Dimplicit-function-declaration]
> > > >   ptep =3D pte_offset_map(pmd, addr);
> > > >
> > >
> > > Similar one.
> > >
> > > http://marc.info/?l=3Dlinux-mm&m=3D137532486405085&w=3D2
> >
> >
> > In this patch MIGRATION config is not required MMU, because already CMA
> > config depends
> > on MMU and HAVE_MEMBLOCK if both are true then only selecting MIGRATION
> and
> > MEMORY_ISOLATION.
>
> No, I think it should be config MIGRATION that should depend on MMU
> explicitly because that is where the problem exists. It shouldn't rely
> on other configs to not select it automatically.
>
>  Yes you are correct.

The question is. Does CMA need to depend on MMU as well? Why?
> But please comment on the original thread instead.
>

I went through the mm/Kconfig, I think MMU dependence is not required
for CMA.


--
> Michal Hocko
> SUSE Labs
>

Thanks
Manjunath Goudar

--90e6ba21219bbae0b904e32f3815
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On 5 August 2013 13:02, Michal Hocko <sp=
an dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@suse.cz" target=3D"_blank">mhoc=
ko@suse.cz</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5">On Mon 05-08-13 10:10:08, Manjunath=
 Goudar wrote:<br>
&gt; On 4 August 2013 13:24, Wanpeng Li &lt;<a href=3D"mailto:liwanp@linux.=
vnet.ibm.com">liwanp@linux.vnet.ibm.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Sun, Aug 04, 2013 at 10:41:01AM +0530, Manjunath Goudar wrote:=
<br>
&gt; &gt; &gt;s patch adds a Kconfig dependency on an MMU being available b=
efore<br>
&gt; &gt; &gt;CMA can be enabled. =A0Without this patch, CMA can be enabled=
 on an<br>
&gt; &gt; &gt;MMU-less system which can lead to issues. This was discovered=
 during<br>
&gt; &gt; &gt;randconfig testing, in which CMA was enabled w/o MMU being en=
abled,<br>
&gt; &gt; &gt;leading to the following error:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; CC =A0 =A0 =A0mm/migrate.o<br>
&gt; &gt; &gt;mm/migrate.c: In function =91remove_migration_pte=92:<br>
&gt; &gt; &gt;mm/migrate.c:134:3: error: implicit declaration of function<b=
r>
&gt; &gt; =91pmd_trans_huge=92<br>
&gt; &gt; &gt;[-Werror=3Dimplicit-function-declaration]<br>
&gt; &gt; &gt; =A0 if (pmd_trans_huge(*pmd))<br>
&gt; &gt; &gt; =A0 ^<br>
&gt; &gt; &gt;mm/migrate.c:137:3: error: implicit declaration of function<b=
r>
&gt; &gt; =91pte_offset_map=92<br>
&gt; &gt; &gt;[-Werror=3Dimplicit-function-declaration]<br>
&gt; &gt; &gt; =A0 ptep =3D pte_offset_map(pmd, addr);<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Similar one.<br>
&gt; &gt;<br>
&gt; &gt; <a href=3D"http://marc.info/?l=3Dlinux-mm&amp;m=3D137532486405085=
&amp;w=3D2" target=3D"_blank">http://marc.info/?l=3Dlinux-mm&amp;m=3D137532=
486405085&amp;w=3D2</a><br>
&gt;<br>
&gt;<br>
&gt; In this patch MIGRATION config is not required MMU, because already CM=
A<br>
&gt; config depends<br>
&gt; on MMU and HAVE_MEMBLOCK if both are true then only selecting MIGRATIO=
N and<br>
&gt; MEMORY_ISOLATION.<br>
<br>
</div></div>No, I think it should be config MIGRATION that should depend on=
 MMU<br>
explicitly because that is where the problem exists. It shouldn&#39;t rely<=
br>
on other configs to not select it automatically.<br>
<br></blockquote><div>=A0Yes you are correct.=A0</div><div><br></div><block=
quote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc=
 solid;padding-left:1ex">
The question is. Does CMA need to depend on MMU as well? Why?<br>
But please comment on the original thread instead.<br></blockquote><div><br=
></div><div>I went=A0through=A0the mm/Kconfig, I think MMU dependence is no=
t required=A0</div><div>for CMA.=A0</div><div><br></div><div><br></div><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #c=
cc solid;padding-left:1ex">

<div class=3D"HOEnZb"><div class=3D"h5">--<br>
Michal Hocko<br>
SUSE Labs<br>
</div></div></blockquote></div><div><br></div>Thanks<div>Manjunath Goudar</=
div>

--90e6ba21219bbae0b904e32f3815--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
