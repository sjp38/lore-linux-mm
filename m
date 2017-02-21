Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 912A96B0387
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 12:42:52 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id h53so120184672qth.6
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 09:42:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y38si15573373qtb.249.2017.02.21.09.42.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 09:42:51 -0800 (PST)
Message-ID: <1487698965.17158.8.camel@redhat.com>
Subject: Re: [RFC PATCH v4 00/28] x86: Secure Memory Encryption (AMD)
From: Rik van Riel <riel@redhat.com>
Date: Tue, 21 Feb 2017 12:42:45 -0500
In-Reply-To: <20170218181209.xk5ut4g65f2fedzi@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
	 <20170218181209.xk5ut4g65f2fedzi@pd.tnic>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Ey+x+8UTgY4YU2q4krvX"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>


--=-Ey+x+8UTgY4YU2q4krvX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2017-02-18 at 19:12 +0100, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:41:59AM -0600, Tom Lendacky wrote:
> >=20
> > =C2=A0create mode 100644 Documentation/x86/amd-memory-encryption.txt
> > =C2=A0create mode 100644 arch/x86/include/asm/mem_encrypt.h
> > =C2=A0create mode 100644 arch/x86/kernel/mem_encrypt_boot.S
> > =C2=A0create mode 100644 arch/x86/kernel/mem_encrypt_init.c
> > =C2=A0create mode 100644 arch/x86/mm/mem_encrypt.c
> I don't see anything standing in the way of merging those last two
> and
> having a single:
>=20
> arch/x86/kernel/mem_encrypt.c

Do we want that in kernel/ or in arch/x86/mm/ ?

--=20
All rights reversed

--=-Ey+x+8UTgY4YU2q4krvX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJYrHwWAAoJEM553pKExN6DJ/UH/RRNhYZrnIp7K+gy9xrMsZUf
c8PTqoSXhuKGEQshsnqSDY04CQkNtkX+RXzkurubq6ExwwIQ76jl0W0/nKwQq7FX
mPAM23P+EQoUCd+G794/5JqSeFkXyJ7YBQKUaunDbIsBtXU/8o9UYAoUqnoiuobw
Qr2sj2f9fIMlvEePsvmpO4G8Ds8IAc1qit50HljGg5+Fi7giD1hvWi6xjL3UZeVc
Re9RSoOe0c6Gi17MhmnNGFPLFen83fV1u48QZPBFQ2lJf0T4eXiPG9e/hVPwTq+c
ytVFMTBuNeMt3M+vlknqRnAcHd+VjJd+5R7fphS8BdzOF6oL93qKr42p2ci0iNY=
=jOTJ
-----END PGP SIGNATURE-----

--=-Ey+x+8UTgY4YU2q4krvX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
