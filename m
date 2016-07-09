Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7736B0253
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 22:44:15 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id v18so132236159qtv.0
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 19:44:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q204si212933ywg.218.2016.07.08.19.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 19:44:14 -0700 (PDT)
Message-ID: <1468032243.13253.59.camel@redhat.com>
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
From: Rik van Riel <riel@redhat.com>
Date: Fri, 08 Jul 2016 22:44:03 -0400
In-Reply-To: <b113b487-acc6-24b8-d58c-425d3c884f4c@redhat.com>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
	 <b113b487-acc6-24b8-d58c-425d3c884f4c@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-WDIYwW63/yu0AaqYDmjB"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S.
 Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com


--=-WDIYwW63/yu0AaqYDmjB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-07-08 at 19:22 -0700, Laura Abbott wrote:
>=C2=A0
> Even with the SLUB fixup I'm still seeing this blow up on my arm64
> system. This is a
> Fedora rawhide kernel + the patches
>=20
> [=C2=A0=C2=A0=C2=A0=C2=A00.666700] usercopy: kernel memory exposure attem=
pt detected from
> fffffc0008b4dd58 (<kernel text>) (8 bytes)
> [=C2=A0=C2=A0=C2=A0=C2=A00.666720] CPU: 2 PID: 79 Comm: modprobe Tainted:
> G=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0W=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A04.7.0-0.rc6.git1.1.hardenedusercopy.fc25.aarch64 #1
> [=C2=A0=C2=A0=C2=A0=C2=A00.666733] Hardware name: AppliedMicro Mustang/Mu=
stang, BIOS
> 1.1.0 Nov 24 2015
> [=C2=A0=C2=A0=C2=A0=C2=A00.666744] Call trace:
> [=C2=A0=C2=A0=C2=A0=C2=A00.666756] [<fffffc0008088a20>] dump_backtrace+0x=
0/0x1e8
> [=C2=A0=C2=A0=C2=A0=C2=A00.666765] [<fffffc0008088c2c>] show_stack+0x24/0=
x30
> [=C2=A0=C2=A0=C2=A0=C2=A00.666775] [<fffffc0008455344>] dump_stack+0xa4/0=
xe0
> [=C2=A0=C2=A0=C2=A0=C2=A00.666785] [<fffffc000828d874>] __check_object_si=
ze+0x6c/0x230
> [=C2=A0=C2=A0=C2=A0=C2=A00.666795] [<fffffc00083a5748>] create_elf_tables=
+0x74/0x420
> [=C2=A0=C2=A0=C2=A0=C2=A00.666805] [<fffffc00082fb1f0>] load_elf_binary+0=
x828/0xb70
> [=C2=A0=C2=A0=C2=A0=C2=A00.666814] [<fffffc0008298b4c>] search_binary_han=
dler+0xb4/0x240
> [=C2=A0=C2=A0=C2=A0=C2=A00.666823] [<fffffc0008299864>] do_execveat_commo=
n+0x63c/0x950
> [=C2=A0=C2=A0=C2=A0=C2=A00.666832] [<fffffc0008299bb4>] do_execve+0x3c/0x=
50
> [=C2=A0=C2=A0=C2=A0=C2=A00.666841] [<fffffc00080e3720>]
> call_usermodehelper_exec_async+0xe8/0x148
> [=C2=A0=C2=A0=C2=A0=C2=A00.666850] [<fffffc0008084a80>] ret_from_fork+0x1=
0/0x50
>=20
> This happens on every call to execve. This seems to be the first
> copy_to_user in
> create_elf_tables. I didn't get a chance to debug and I'm going out
> of town
> all of next week so all I have is the report unfortunately. config
> attached.

That's odd, this should be copying a piece of kernel data (not text)
to userspace.

from fs/binfmt_elf.c

=C2=A0 =C2=A0 =C2=A0 =C2=A0 const char *k_platform =3D ELF_PLATFORM;

...
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size_t len =3D strl=
en(k_platform) + 1;
	=09
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u_platform =3D (elf=
_addr_t __user *)STACK_ALLOC(p, len);
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0if (__copy_to_user(u_platform, k_platform, len))
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return=
 -EFAULT;

from arch/arm/include/asm/elf.h:

#define ELF_PLATFORM_SIZE 8
#define ELF_PLATFORM=C2=A0=C2=A0=C2=A0=C2=A0(elf_platform)

extern char elf_platform[];

from arch/arm/kernel/setup.c:

char elf_platform[ELF_PLATFORM_SIZE];
EXPORT_SYMBOL(elf_platform);

...

=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0snprintf(elf_platform, ELF_=
PLATFORM_SIZE, "%s%c",
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0list->elf_name, ENDIANNESS);

How does that end up in the .text section of the
image, instead of in one of the various data sections?

What kind of linker oddity is going on with ARM?

--=C2=A0	=09
All Rights Reversed.
--=-WDIYwW63/yu0AaqYDmjB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXgGT0AAoJEM553pKExN6DH7wH/0znCffUzWBhau8KJMvAnoPK
2C47QOWO1LqeYiuIoC3yiTbqFOhHvoqLSNvBp6YmLJDnSDgYPI8/BYHsu4kLLI0e
yB0Gdczy2FQvfp5C3wvahbLkD8llhl/W4DOKfR7BtU3oUWHlQV00rz4qgV1H5uvf
7mied4PFhk8Eabnl1GDcyIm4YZN93P17xqQzYLDc7IL79I79f5wSysmjLGD/slIN
BP+5skId75PKMBrKkLdvD6y02VIgj0gILZyCsHlJRJ/LRfCmN1c9VXShmwd0FO0r
oWiYUCRSZePuKHGuJh67xJknHH7PVvvUDyCrRRSS0dqNO3I/0AD1v9yuyt2eX2E=
=+yIR
-----END PGP SIGNATURE-----

--=-WDIYwW63/yu0AaqYDmjB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
