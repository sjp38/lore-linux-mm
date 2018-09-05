Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E44B6B74EA
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 16:09:26 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id q26-v6so9142966qtj.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 13:09:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m89-v6sor1302013qkl.71.2018.09.05.13.09.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 13:09:25 -0700 (PDT)
MIME-Version: 1.0
References: <1535356775-20396-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180830214856.cwqyjksz36ujxydm@pburton-laptop> <20180831211747.GA31133@rapoport-lnx>
 <20180905174709.pz2rmyt2oob6bxpz@pburton-laptop> <20180905183751.GA4518@rapoport-lnx>
In-Reply-To: <20180905183751.GA4518@rapoport-lnx>
From: "Fancer's opinion" <fancer.lancer@gmail.com>
Date: Wed, 5 Sep 2018 23:09:13 +0300
Message-ID: <CAMPMW8rJ4qC8iaRa0jTjgZmiYf51AaricrgCg1aNx-Ez6=zT0g@mail.gmail.com>
Subject: Re: [PATCH RESEND] mips: switch to NO_BOOTMEM
Content-Type: multipart/alternative; boundary="000000000000d6f2370575255932"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Paul Burton <paul.burton@mips.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, Linux-MIPS <linux-mips@linux-mips.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

--000000000000d6f2370575255932
Content-Type: text/plain; charset="UTF-8"

Hello, Mike
Could you CC me next time you send that larger patchset?

-Sergey


On Wed, Sep 5, 2018 at 9:38 PM Mike Rapoport <rppt@linux.vnet.ibm.com>
wrote:

> On Wed, Sep 05, 2018 at 10:47:10AM -0700, Paul Burton wrote:
> > Hi Mike,
> >
> > On Sat, Sep 01, 2018 at 12:17:48AM +0300, Mike Rapoport wrote:
> > > On Thu, Aug 30, 2018 at 02:48:57PM -0700, Paul Burton wrote:
> > > > On Mon, Aug 27, 2018 at 10:59:35AM +0300, Mike Rapoport wrote:
> > > > > MIPS already has memblock support and all the memory is already
> registered
> > > > > with it.
> > > > >
> > > > > This patch replaces bootmem memory reservations with memblock ones
> and
> > > > > removes the bootmem initialization.
> > > > >
> > > > > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > > > > ---
> > > > >
> > > > >  arch/mips/Kconfig                      |  1 +
> > > > >  arch/mips/kernel/setup.c               | 89
> +++++-----------------------------
> > > > >  arch/mips/loongson64/loongson-3/numa.c | 34 ++++++-------
> > > > >  arch/mips/sgi-ip27/ip27-memory.c       | 11 ++---
> > > > >  4 files changed, 33 insertions(+), 102 deletions(-)
> > > >
> > > > Thanks for working on this. Unfortunately it breaks boot for at
> least a
> > > > 32r6el_defconfig kernel on QEMU:
> > > >
> > > >   $ qemu-system-mips64el \
> > > >     -M boston \
> > > >     -kernel arch/mips/boot/vmlinux.gz.itb \
> > > >     -serial stdio \
> > > >     -append "earlycon=uart8250,mmio32,0x17ffe000,115200
> console=ttyS0,115200 debug memblock=debug mminit_loglevel=4"
> > > >   [    0.000000] Linux version 4.19.0-rc1-00008-g82d0f342eecd
> (pburton@pburton-laptop) (gcc version 8.1.0 (GCC)) #23 SMP Thu Aug 30
> 14:38:06 PDT 2018
> > > >   [    0.000000] CPU0 revision is: 0001a900 (MIPS I6400)
> > > >   [    0.000000] FPU revision is: 20f30300
> > > >   [    0.000000] MSA revision is: 00000300
> > > >   [    0.000000] MIPS: machine is img,boston
> > > >   [    0.000000] Determined physical RAM map:
> > > >   [    0.000000]  memory: 10000000 @ 00000000 (usable)
> > > >   [    0.000000]  memory: 30000000 @ 90000000 (usable)
> > > >   [    0.000000] earlycon: uart8250 at MMIO32 0x17ffe000 (options
> '115200')
> > > >   [    0.000000] bootconsole [uart8250] enabled
> > > >   [    0.000000] memblock_reserve: [0x00000000-0x009a8fff]
> setup_arch+0x224/0x718
> > > >   [    0.000000] memblock_reserve: [0x01360000-0x01361ca7]
> setup_arch+0x3d8/0x718
> > > >   [    0.000000] Initrd not found or empty - disabling initrd
> > > >   [    0.000000] memblock_virt_alloc_try_nid: 7336 bytes align=0x40
> nid=-1 from=0x00000000 max_addr=0x00000000
> early_init_dt_alloc_memory_arch+0x20/0x2c
> > > >   [    0.000000] memblock_reserve: [0xbfffe340-0xbfffffe7]
> memblock_virt_alloc_internal+0x120/0x1ec
> > > >   <hang>
> > > >
> > > > It looks like we took a TLB store exception after calling memset()
> with
> > > > a bogus address from memblock_virt_alloc_try_nid() or something
> inlined
> > > > into it.
> > >
> > > Memblock tries to allocate from the top and the resulting address ends
> up
> > > in the high memory.
> > >
> > > With the hunk below I was able to get to "VFS: Cannot open root device"
> > >
> > > diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
> > > index 4114d3c..4a9b0f7 100644
> > > --- a/arch/mips/kernel/setup.c
> > > +++ b/arch/mips/kernel/setup.c
> > > @@ -577,6 +577,8 @@ static void __init bootmem_init(void)
> > >          * Reserve initrd memory if needed.
> > >          */
> > >         finalize_initrd();
> > > +
> > > +       memblock_set_bottom_up(true);
> > >  }
> >
> > That does seem to fix it, and some basic tests are looking good.
>
> The bottom up mode has the downside of allocating memory below
> MAX_DMA_ADDRESS.
>
> I'd like to check if memblock_set_current_limit(max_low_pfn) will also fix
> the issue, at least with the limited tests I can do with qemu.
>
> > I notice you submitted this as part of your larger series to remove
> > bootmem - are you still happy for me to take this one through mips-next?
>
> Sure, I've just posted it as the part of the larger series for
> completeness.
>
> I believe that in the next few days I'll be able to verify whether
> memblock_set_current_limit() can be used instead of
> memblock_set_bottom_up() and I'll resend the patch then.
>
> > Thanks,
> >     Paul
> >
>
> --
> Sincerely yours,
> Mike.
>
>

--000000000000d6f2370575255932
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hello, Mike</div>Could you CC me next time you send t=
hat larger patchset?<div><br></div><div>-Sergey</div><div><br></div></div><=
br><div class=3D"gmail_quote"><div dir=3D"ltr">On Wed, Sep 5, 2018 at 9:38 =
PM Mike Rapoport &lt;<a href=3D"mailto:rppt@linux.vnet.ibm.com">rppt@linux.=
vnet.ibm.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On Wed,=
 Sep 05, 2018 at 10:47:10AM -0700, Paul Burton wrote:<br>
&gt; Hi Mike,<br>
&gt; <br>
&gt; On Sat, Sep 01, 2018 at 12:17:48AM +0300, Mike Rapoport wrote:<br>
&gt; &gt; On Thu, Aug 30, 2018 at 02:48:57PM -0700, Paul Burton wrote:<br>
&gt; &gt; &gt; On Mon, Aug 27, 2018 at 10:59:35AM +0300, Mike Rapoport wrot=
e:<br>
&gt; &gt; &gt; &gt; MIPS already has memblock support and all the memory is=
 already registered<br>
&gt; &gt; &gt; &gt; with it.<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; This patch replaces bootmem memory reservations with me=
mblock ones and<br>
&gt; &gt; &gt; &gt; removes the bootmem initialization.<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; Signed-off-by: Mike Rapoport &lt;<a href=3D"mailto:rppt=
@linux.vnet.ibm.com" target=3D"_blank">rppt@linux.vnet.ibm.com</a>&gt;<br>
&gt; &gt; &gt; &gt; ---<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt;=C2=A0 arch/mips/Kconfig=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 1 +<br>
&gt; &gt; &gt; &gt;=C2=A0 arch/mips/kernel/setup.c=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 89 +++++-----------------------------<br>
&gt; &gt; &gt; &gt;=C2=A0 arch/mips/loongson64/loongson-3/numa.c | 34 +++++=
+-------<br>
&gt; &gt; &gt; &gt;=C2=A0 arch/mips/sgi-ip27/ip27-memory.c=C2=A0 =C2=A0 =C2=
=A0 =C2=A0| 11 ++---<br>
&gt; &gt; &gt; &gt;=C2=A0 4 files changed, 33 insertions(+), 102 deletions(=
-)<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; Thanks for working on this. Unfortunately it breaks boot for=
 at least a<br>
&gt; &gt; &gt; 32r6el_defconfig kernel on QEMU:<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt;=C2=A0 =C2=A0$ qemu-system-mips64el \<br>
&gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0-M boston \<br>
&gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0-kernel arch/mips/boot/vmlinux.gz.itb \<b=
r>
&gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0-serial stdio \<br>
&gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0-append &quot;earlycon=3Duart8250,mmio32,=
0x17ffe000,115200 console=3DttyS0,115200 debug memblock=3Ddebug mminit_logl=
evel=3D4&quot;<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] Linux version 4.19.0-rc=
1-00008-g82d0f342eecd (pburton@pburton-laptop) (gcc version 8.1.0 (GCC)) #2=
3 SMP Thu Aug 30 14:38:06 PDT 2018<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] CPU0 revision is: 0001a=
900 (MIPS I6400)<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] FPU revision is: 20f303=
00<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] MSA revision is: 000003=
00<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] MIPS: machine is img,bo=
ston<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] Determined physical RAM=
 map:<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000]=C2=A0 memory: 10000000 =
@ 00000000 (usable)<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000]=C2=A0 memory: 30000000 =
@ 90000000 (usable)<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] earlycon: uart8250 at M=
MIO32 0x17ffe000 (options &#39;115200&#39;)<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] bootconsole [uart8250] =
enabled<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] memblock_reserve: [0x00=
000000-0x009a8fff] setup_arch+0x224/0x718<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] memblock_reserve: [0x01=
360000-0x01361ca7] setup_arch+0x3d8/0x718<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] Initrd not found or emp=
ty - disabling initrd<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] memblock_virt_alloc_try=
_nid: 7336 bytes align=3D0x40 nid=3D-1 from=3D0x00000000 max_addr=3D0x00000=
000 early_init_dt_alloc_memory_arch+0x20/0x2c<br>
&gt; &gt; &gt;=C2=A0 =C2=A0[=C2=A0 =C2=A0 0.000000] memblock_reserve: [0xbf=
ffe340-0xbfffffe7] memblock_virt_alloc_internal+0x120/0x1ec<br>
&gt; &gt; &gt;=C2=A0 =C2=A0&lt;hang&gt;<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; It looks like we took a TLB store exception after calling me=
mset() with<br>
&gt; &gt; &gt; a bogus address from memblock_virt_alloc_try_nid() or someth=
ing inlined<br>
&gt; &gt; &gt; into it.<br>
&gt; &gt; <br>
&gt; &gt; Memblock tries to allocate from the top and the resulting address=
 ends up<br>
&gt; &gt; in the high memory. <br>
&gt; &gt; <br>
&gt; &gt; With the hunk below I was able to get to &quot;VFS: Cannot open r=
oot device&quot;<br>
&gt; &gt; <br>
&gt; &gt; diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c<=
br>
&gt; &gt; index 4114d3c..4a9b0f7 100644<br>
&gt; &gt; --- a/arch/mips/kernel/setup.c<br>
&gt; &gt; +++ b/arch/mips/kernel/setup.c<br>
&gt; &gt; @@ -577,6 +577,8 @@ static void __init bootmem_init(void)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Reserve initrd memory if need=
ed.<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0finalize_initrd();<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0memblock_set_bottom_up(true);<br>
&gt; &gt;=C2=A0 }<br>
&gt; <br>
&gt; That does seem to fix it, and some basic tests are looking good.<br>
<br>
The bottom up mode has the downside of allocating memory below<br>
MAX_DMA_ADDRESS. <br>
<br>
I&#39;d like to check if memblock_set_current_limit(max_low_pfn) will also =
fix<br>
the issue, at least with the limited tests I can do with qemu.<br>
<br>
&gt; I notice you submitted this as part of your larger series to remove<br=
>
&gt; bootmem - are you still happy for me to take this one through mips-nex=
t?<br>
<br>
Sure, I&#39;ve just posted it as the part of the larger series for complete=
ness.<br>
<br>
I believe that in the next few days I&#39;ll be able to verify whether<br>
memblock_set_current_limit() can be used instead of<br>
memblock_set_bottom_up() and I&#39;ll resend the patch then.<br>
<br>
&gt; Thanks,<br>
&gt;=C2=A0 =C2=A0 =C2=A0Paul<br>
&gt; <br>
<br>
-- <br>
Sincerely yours,<br>
Mike.<br>
<br>
</blockquote></div>

--000000000000d6f2370575255932--
