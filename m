Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECA96B000C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 11:13:09 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s14-v6so5018450ioc.0
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:13:09 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 82-v6sor7841441iod.303.2018.07.11.08.13.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 08:13:07 -0700 (PDT)
MIME-Version: 1.0
References: <20180710235044.vjlRV%akpm@linux-foundation.org>
 <87lgai9bt5.fsf@concordia.ellerman.id.au> <20180711133737.GA29573@techadventures.net>
 <CAGM2reYsSi5kDGtnTQASnp1v49T8Y+9o_pNxmSq-+m68QhF2Tg@mail.gmail.com>
In-Reply-To: <CAGM2reYsSi5kDGtnTQASnp1v49T8Y+9o_pNxmSq-+m68QhF2Tg@mail.gmail.com>
From: Oscar Salvador <osalvador.vilardaga@gmail.com>
Date: Wed, 11 Jul 2018 17:13:00 +0200
Message-ID: <CAOXBz7ixEK85S-029XrM4+g4fxtSY6_tke0gcQ-hOXFCb7wcZg@mail.gmail.com>
Subject: Re: Boot failures with "mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER"
 on powerpc (was Re: mmotm 2018-07-10-16-50 uploaded)
Content-Type: multipart/alternative; boundary="000000000000153f660570baafbd"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: mpe@ellerman.id.au, Andrew Morton <akpm@linux-foundation.org>, broonie@kernel.org, mhocko@suse.cz, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, mm-commits@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, bhe@redhat.com, aneesh.kumar@linux.ibm.com, khandual@linux.vnet.ibm.com

--000000000000153f660570baafbd
Content-Type: text/plain; charset="UTF-8"

El dc., 11 jul. 2018 , 15:56, Pavel Tatashin <pasha.tatashin@oracle.com> va
escriure:

> I am OK, if this patch is removed from Baoquan's series. But, I would
> still like to get rid of CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER, I
> can work on this in my sparse_init re-write series. ppc64 should
> really fallback safely to small chunks allocs, and if it does not
> there is some existing bug. Michael please send the config that you
> used.
>
> Thank you,
> Pavel
> On Wed, Jul 11, 2018 at 9:37 AM Oscar Salvador
> <osalvador@techadventures.net> wrote:
> >
> > On Wed, Jul 11, 2018 at 10:49:58PM +1000, Michael Ellerman wrote:
> > > akpm@linux-foundation.org writes:
> > > > The mm-of-the-moment snapshot 2018-07-10-16-50 has been uploaded to
> > > >
> > > >    http://www.ozlabs.org/~akpm/mmotm/
> > > ...
> > >
> > > > * mm-sparse-add-a-static-variable-nr_present_sections.patch
> > > > * mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
> > > > * mm-sparsemem-defer-the-ms-section_mem_map-clearing-fix.patch
> > > > *
> mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
> > > > * mm-sparse-optimize-memmap-allocation-during-sparse_init.patch
> > > > *
> mm-sparse-optimize-memmap-allocation-during-sparse_init-checkpatch-fixes.patch
> > >
> > > > * mm-sparse-remove-config_sparsemem_alloc_mem_map_together.patch
> > >
> > > This seems to be breaking my powerpc pseries qemu boots.
> > >
> > > The boot log with some extra debug shows eg:
> > >
> > >   $ make pseries_le_defconfig
> >
> > Could you please share the config?
> > I was not able to find such config in the kernel tree.
> > --
> > Oscar Salvador
> > SUSE L3
> >
>
>
>
>
> I just roughly check, but if I checked the right place,
vmemmap_populated() checks for the section to contain the flags we are
setting in sparse_init_one_section().
But with this patch, we populate first everything, and then we call
sparse_init_one_section() in sparse_init().
As I said I could be mistaken because I just checked the surface.
I plan to further look into it tomorrow.
(Sorry I dont know how to disable html in gmail)

--000000000000153f660570baafbd
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">=
El dc., 11 jul. 2018 , 15:56, Pavel Tatashin &lt;<a href=3D"mailto:pasha.ta=
tashin@oracle.com" rel=3D"noreferrer noreferrer" target=3D"_blank">pasha.ta=
tashin@oracle.com</a>&gt; va escriure:<br></div><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex">I am OK, if this patch is removed from Baoquan&#39;s series. But, I wou=
ld<br>
still like to get rid of CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER, I<br>
can work on this in my sparse_init re-write series. ppc64 should<br>
really fallback safely to small chunks allocs, and if it does not<br>
there is some existing bug. Michael please send the config that you<br>
used.<br>
<br>
Thank you,<br>
Pavel<br>
On Wed, Jul 11, 2018 at 9:37 AM Oscar Salvador<br>
&lt;<a href=3D"mailto:osalvador@techadventures.net" rel=3D"noreferrer noref=
errer noreferrer" target=3D"_blank">osalvador@techadventures.net</a>&gt; wr=
ote:<br>
&gt;<br>
&gt; On Wed, Jul 11, 2018 at 10:49:58PM +1000, Michael Ellerman wrote:<br>
&gt; &gt; <a href=3D"mailto:akpm@linux-foundation.org" rel=3D"noreferrer no=
referrer noreferrer" target=3D"_blank">akpm@linux-foundation.org</a> writes=
:<br>
&gt; &gt; &gt; The mm-of-the-moment snapshot 2018-07-10-16-50 has been uplo=
aded to<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;=C2=A0 =C2=A0 <a href=3D"http://www.ozlabs.org/~akpm/mmotm/" =
rel=3D"noreferrer noreferrer noreferrer noreferrer" target=3D"_blank">http:=
//www.ozlabs.org/~akpm/mmotm/</a><br>
&gt; &gt; ...<br>
&gt; &gt;<br>
&gt; &gt; &gt; * mm-sparse-add-a-static-variable-nr_present_sections.patch<=
br>
&gt; &gt; &gt; * mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch<b=
r>
&gt; &gt; &gt; * mm-sparsemem-defer-the-ms-section_mem_map-clearing-fix.pat=
ch<br>
&gt; &gt; &gt; * mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_use=
map_and_memmap.patch<br>
&gt; &gt; &gt; * mm-sparse-optimize-memmap-allocation-during-sparse_init.pa=
tch<br>
&gt; &gt; &gt; * mm-sparse-optimize-memmap-allocation-during-sparse_init-ch=
eckpatch-fixes.patch<br>
&gt; &gt;<br>
&gt; &gt; &gt; * mm-sparse-remove-config_sparsemem_alloc_mem_map_together.p=
atch<br>
&gt; &gt;<br>
&gt; &gt; This seems to be breaking my powerpc pseries qemu boots.<br>
&gt; &gt;<br>
&gt; &gt; The boot log with some extra debug shows eg:<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0$ make pseries_le_defconfig<br>
&gt;<br>
&gt; Could you please share the config?<br>
&gt; I was not able to find such config in the kernel tree.<br>
&gt; --<br>
&gt; Oscar Salvador<br>
&gt; SUSE L3<br>
&gt;<br>
<br>
</blockquote><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;b=
order-left:1px #ccc solid;padding-left:1ex"><br></blockquote><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;p=
adding-left:1ex"><br></blockquote><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><br></bl=
ockquote><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex"></blockquote></div></div><div dir=
=3D"auto">I just roughly check, but if I checked the right place, vmemmap_p=
opulated() checks for the section to contain the flags we are setting in sp=
arse_init_one_section().</div><div dir=3D"auto">But with this patch, we pop=
ulate first everything, and then we call sparse_init_one_section() in spars=
e_init().</div><div dir=3D"auto">As I said I could be mistaken because I ju=
st checked the surface.</div><div dir=3D"auto">I plan to further look into =
it tomorrow.</div><div dir=3D"auto">(Sorry I dont know how to disable html =
in gmail)</div><div dir=3D"auto"><br></div><div dir=3D"auto"></div></div>

--000000000000153f660570baafbd--
