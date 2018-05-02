Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9486B000C
	for <linux-mm@kvack.org>; Wed,  2 May 2018 16:11:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c4so13678855pfg.22
        for <linux-mm@kvack.org>; Wed, 02 May 2018 13:11:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m11-v6si10280680pgs.73.2018.05.02.13.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 13:11:31 -0700 (PDT)
Date: Wed, 2 May 2018 21:11:25 +0100
From: James Hogan <jhogan@kernel.org>
Subject: Re: [PATCH 07/13] arch: remove the ARCH_PHYS_ADDR_T_64BIT config
 symbol
Message-ID: <20180502201123.GA20766@jamesdev>
References: <20180425051539.1989-1-hch@lst.de>
 <20180425051539.1989-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="6TrnltStXW4iwmi0"
Content-Disposition: inline
In-Reply-To: <20180425051539.1989-8-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org, sstabellini@kernel.org, x86@kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 25, 2018 at 07:15:33AM +0200, Christoph Hellwig wrote:
> Instead select the PHYS_ADDR_T_64BIT for 32-bit architectures that need a
> 64-bit phys_addr_t type directly.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>

>  arch/mips/Kconfig                      | 15 ++++++---------

For MIPS:
Acked-by: James Hogan <jhogan@kernel.org>

Cheers
James

--6TrnltStXW4iwmi0
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEARYIAB0WIQS7lRNBWUYtqfDOVL41zuSGKxAj8gUCWuobYAAKCRA1zuSGKxAj
8rcSAP9uo9v+ADH7S0A5ptU5zQJbehcDNcjsP+tV3mIWaMxo5AD9Fxc2fxERhWzk
sHBf3K14mN5e+PiMMLB9/hGD7t8eJAo=
=7djd
-----END PGP SIGNATURE-----

--6TrnltStXW4iwmi0--
