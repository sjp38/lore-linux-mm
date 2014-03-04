Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id B88626B0039
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 20:03:18 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so4434466pbc.21
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 17:03:18 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [203.10.76.45])
        by mx.google.com with ESMTPS id tk9si12327368pac.6.2014.03.03.17.03.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Mar 2014 17:03:17 -0800 (PST)
Date: Tue, 4 Mar 2014 12:03:02 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2014-03-03-15-24 uploaded
Message-Id: <20140304120302.7ee7f3a89b0e3c088479230d@canb.auug.org.au>
In-Reply-To: <20140303163921.48ab37bdfd9b895ee985a776@linux-foundation.org>
References: <20140303232530.2AC4131C2A3@corp2gmr1-1.hot.corp.google.com>
	<20140304113610.a033faa8e5d3afeb38f7ac79@canb.auug.org.au>
	<20140303163921.48ab37bdfd9b895ee985a776@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__4_Mar_2014_12_03_02_+1100_Bw.nM=fy=yqb65yh"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>, Geert Uytterhoeven <geert@linux-m68k.org>

--Signature=_Tue__4_Mar_2014_12_03_02_+1100_Bw.nM=fy=yqb65yh
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__4_Mar_2014_12_03_02_+1100_XeFjU_yk4y+pNlFY"


--Multipart=_Tue__4_Mar_2014_12_03_02_+1100_XeFjU_yk4y+pNlFY
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Mon, 3 Mar 2014 16:39:21 -0800 Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>
> On Tue, 4 Mar 2014 11:36:10 +1100 Stephen Rothwell <sfr@canb.auug.org.au>=
 wrote:
>=20
> > I am carrying 5 fix patches for the above patch (they need to go before
> > or as part of the above patch).
> >=20
> > ppc_Make_PPC_BOOK3S_64_select_IRQ_WORK.patch
> > ia64__select_CONFIG_TTY_for_use_of_tty_write_message_in_unaligned.patch
> > s390__select_CONFIG_TTY_for_use_of_tty_in_unconditional_keyboard_driver=
.patch
> > cris__Make_ETRAX_ARCH_V10_select_TTY_for_use_in_debugport.patch
> > cris__cpuinfo_op_should_depend_on_CONFIG_PROC_FS.patch
> >=20
> > I can send them to you if you like,
>=20
> Yes please.
>=20
> > but I am pretty sure you were cc'd on all of them.
>=20
> I hoped someone else was collecting them ;)

Attached (I hope that works for you)
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Multipart=_Tue__4_Mar_2014_12_03_02_+1100_XeFjU_yk4y+pNlFY
Content-Type: text/x-diff;
 name="ppc_Make_PPC_BOOK3S_64_select_IRQ_WORK.patch"
Content-Disposition: attachment;
 filename="ppc_Make_PPC_BOOK3S_64_select_IRQ_WORK.patch"
Content-Transfer-Encoding: quoted-printable

From: Josh Triplett <josh@joshtriplett.org>
Date: Wed, 26 Feb 2014 01:58:02 -0800
Subject: [PATCH] ppc: Make PPC_BOOK3S_64 select IRQ_WORK

arch/powerpc/kernel/mce.c, compiled in for PPC_BOOK3S_64, calls
functions only built when IRQ_WORK, so select it.  Fixes the following
build error:

arch/powerpc/kernel/built-in.o: In function `.machine_check_queue_event':
(.text+0x11260): undefined reference to `.irq_work_queue'

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 arch/powerpc/platforms/Kconfig.cputype | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platform=
s/Kconfig.cputype
index 434fda3..d9e2b19 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -73,6 +73,7 @@ config PPC_BOOK3S_64
 	select SYS_SUPPORTS_HUGETLBFS
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE if PPC_64K_PAGES
 	select ARCH_SUPPORTS_NUMA_BALANCING
+	select IRQ_WORK
=20
 config PPC_BOOK3E_64
 	bool "Embedded processors"
--=20
1.9.0


--Multipart=_Tue__4_Mar_2014_12_03_02_+1100_XeFjU_yk4y+pNlFY
Content-Type: text/x-diff;
 name="ia64__select_CONFIG_TTY_for_use_of_tty_write_message_in_unaligned.patch"
Content-Disposition: attachment;
 filename="ia64__select_CONFIG_TTY_for_use_of_tty_write_message_in_unaligned.patch"
Content-Transfer-Encoding: quoted-printable

From: Josh Triplett <josh@joshtriplett.org>
To: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management Lis=
t <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes=
 Weiner <hannes@cmpxchg.org>, kbuild-all@01.org, Tony Luck <tony.luck@intel=
.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux=
-kernel@vger.kernel.org
Subject: [PATCH] ia64: select CONFIG_TTY for use of tty_write_message in un=
aligned
Date: Wed, 26 Feb 2014 02:15:56 -0800

arch/ia64/kernel/unaligned.c uses tty_write_message to print an
unaligned access exception to the TTY of the current user process.
Enable TTY to prevent a build error.

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
Not tested, but this *should* fix the build error with CONFIG_TTY=3Dn.

Minimal fix, on the basis that few people on ia64 will care deeply about
kernel size enough to turn off TTY.  Ideally, I'd instead suggest
dropping the tty_write_message entirely, and just leaving the printk.
Bonus: no need to sprintf first.

 arch/ia64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 0c8e553..6b83c66 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -44,6 +44,7 @@ config IA64
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select TTY
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
--=20
1.9.0


--Multipart=_Tue__4_Mar_2014_12_03_02_+1100_XeFjU_yk4y+pNlFY
Content-Type: text/x-diff;
 name="s390__select_CONFIG_TTY_for_use_of_tty_in_unconditional_keyboard_driver.patch"
Content-Disposition: attachment;
 filename="s390__select_CONFIG_TTY_for_use_of_tty_in_unconditional_keyboard_driver.patch"
Content-Transfer-Encoding: quoted-printable

From: Josh Triplett <josh@joshtriplett.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, =
linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, =
Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, linux-s390=
@vger.kernel.org
Subject: [PATCH] s390: select CONFIG_TTY for use of tty in unconditional ke=
yboard driver
Date: Wed, 26 Feb 2014 18:13:06 -0800

The unconditionally built keyboard driver, drivers/s390/char/keyboard.c,
requires CONFIG_TTY, so select it from CONFIG_S390 to prevent a build
error.

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 arch/s390/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 65a0775..398efa1 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -140,6 +140,7 @@ config S390
 	select OLD_SIGACTION
 	select OLD_SIGSUSPEND3
 	select SYSCTL_EXCEPTION_TRACE
+	select TTY
 	select VIRT_CPU_ACCOUNTING
 	select VIRT_TO_BUS
=20
--=20
1.9.0


--Multipart=_Tue__4_Mar_2014_12_03_02_+1100_XeFjU_yk4y+pNlFY
Content-Type: text/x-diff;
 name="cris__Make_ETRAX_ARCH_V10_select_TTY_for_use_in_debugport.patch"
Content-Disposition: attachment;
 filename="cris__Make_ETRAX_ARCH_V10_select_TTY_for_use_in_debugport.patch"
Content-Transfer-Encoding: quoted-printable

From: Josh Triplett <josh@joshtriplett.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, =
linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>, Jesper Nil=
sson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com
Subject: [PATCH] cris: Make ETRAX_ARCH_V10 select TTY for use in debugport
Date: Thu, 27 Feb 2014 17:27:34 -0800

arch/cris/arch-v10/kernel/debugport.c, compiled in unconditionally with
ETRAX_ARCH_V10, requires TTY, so select TTY to avoid a build failure.

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 arch/cris/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/cris/Kconfig b/arch/cris/Kconfig
index ed0fcdf..7cb90a5 100644
--- a/arch/cris/Kconfig
+++ b/arch/cris/Kconfig
@@ -138,6 +138,7 @@ config ETRAX_ARCH_V10
        bool
        default y if ETRAX100LX || ETRAX100LX_V2
        default n if !(ETRAX100LX || ETRAX100LX_V2)
+       select TTY
=20
 config ETRAX_ARCH_V32
        bool
--=20
1.9.0


--Multipart=_Tue__4_Mar_2014_12_03_02_+1100_XeFjU_yk4y+pNlFY
Content-Type: text/x-diff;
 name="cris__cpuinfo_op_should_depend_on_CONFIG_PROC_FS.patch"
Content-Disposition: attachment;
 filename="cris__cpuinfo_op_should_depend_on_CONFIG_PROC_FS.patch"
Content-Transfer-Encoding: quoted-printable

From: Geert Uytterhoeven <geert@linux-m68k.org>
To: Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.=
com>
Cc: linux-cris-kernel@axis.com, linux-next@vger.kernel.org, linux-kernel@vg=
er.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH -next] cris: cpuinfo_op should depend on CONFIG_PROC_FS
Date: Sun,  2 Mar 2014 11:34:39 +0100

Now allnoconfig started disabling CONFIG_PROC_FS:

    arch/cris/kernel/built-in.o:(.rodata+0xc): undefined reference to `show=
_cpuinfo'
    make: *** [vmlinux] Error 1

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
http://kisskb.ellerman.id.au/kisskb/buildresult/10665698/

 arch/cris/kernel/setup.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/cris/kernel/setup.c b/arch/cris/kernel/setup.c
index 32c3d248868e..905b70ea9939 100644
--- a/arch/cris/kernel/setup.c
+++ b/arch/cris/kernel/setup.c
@@ -165,6 +165,7 @@ void __init setup_arch(char **cmdline_p)
 	strcpy(init_utsname()->machine, cris_machine_name);
 }
=20
+#ifdef CONFIG_PROC_FS
 static void *c_start(struct seq_file *m, loff_t *pos)
 {
 	return *pos < nr_cpu_ids ? (void *)(int)(*pos + 1) : NULL;
@@ -188,6 +189,7 @@ const struct seq_operations cpuinfo_op =3D {
 	.stop  =3D c_stop,
 	.show  =3D show_cpuinfo,
 };
+#endif /* CONFIG_PROC_FS */
=20
 static int __init topology_init(void)
 {
--=20
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-next" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Multipart=_Tue__4_Mar_2014_12_03_02_+1100_XeFjU_yk4y+pNlFY--

--Signature=_Tue__4_Mar_2014_12_03_02_+1100_Bw.nM=fy=yqb65yh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIbBAEBCAAGBQJTFSZPAAoJEMDTa8Ir7ZwV7/wP91zhetpr5izIcbu5crO0emzA
87uBGITynOQTOZUoPmtCZoUVyPG2LVids6+S7TOzTz8Wx6JSSw/6j7xlW938u0cV
B2EWqf+88BHU+6b4bMgYXlFtCVFVqAp0zLOwRrk40jN+2Qw+MSztBhdkyLIbnGMQ
XDQmH6Jz9vuBSJjos1zJlChavk4Kp6KgQ3fK3lDeAMq/jsZT0LLrAJyrdWIgpeph
szNMTfUg7FnLhjZ9ZxeEelmdzzJjNDUmMz0ngkzoOG8pr+yzD0wsWpd6WKSlyHIQ
2lzwN4oraTpe4SNgkJrzaZ+HTlX2bIEXUAnPeFNSstHf6XyYgQFtzBILi+3tL2u/
ubk5X4d5SvceEjhl+0qSGZbE6FFGrYqCUyWvBjQGoONsRzvb3wbo8p5NPqwzYnhi
tzwj8i8YJycOZxaLIWHsgZM5dEpUb/3b7kyCV/pQ6IgsouQXHZHboEV4nf7gofCt
nGq9PfYk7b7oA935JO0Euw7d7Kk9jOALJ0puxZ9I+RxO2/krRjUe2l2GAGF64uj0
fiY6rokce4X1e2Z5Ywq5QO0bOunnx1HNToOJHA4WfT6nJ4hD6dkhjspu80+mOtWB
CDeWtlX36WdvfjQKDFbME6qzS8uRvvhbkLgMMAhz9l2CjqNS5nYafN0gsoAGUXT1
MfC0xGJ275UuZFQZfSs=
=G6Tb
-----END PGP SIGNATURE-----

--Signature=_Tue__4_Mar_2014_12_03_02_+1100_Bw.nM=fy=yqb65yh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
