Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF1106B0006
	for <linux-mm@kvack.org>; Wed,  2 May 2018 18:09:40 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s8-v6so11015812pgf.0
        for <linux-mm@kvack.org>; Wed, 02 May 2018 15:09:40 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id ay2-v6si10726078plb.210.2018.05.02.15.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 15:09:39 -0700 (PDT)
Date: Wed, 2 May 2018 23:09:34 +0100
From: James Hogan <jhogan@kernel.org>
Subject: Re: [PATCH 08/13] arch: define the ARCH_DMA_ADDR_T_64BIT config
 symbol in lib/Kconfig
Message-ID: <20180502220933.GB20766@jamesdev>
References: <20180425051539.1989-1-hch@lst.de>
 <20180425051539.1989-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="wzJLGUyc3ArbnUjN"
Content-Disposition: inline
In-Reply-To: <20180425051539.1989-9-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org, sstabellini@kernel.org, x86@kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org


--wzJLGUyc3ArbnUjN
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 25, 2018 at 07:15:34AM +0200, Christoph Hellwig wrote:
> Define this symbol if the architecture either uses 64-bit pointers or the
> PHYS_ADDR_T_64BIT is set.  This covers 95% of the old arch magic.  We only
> need an additional select for Xen on ARM (why anyway?), and we now always
> set ARCH_DMA_ADDR_T_64BIT on mips boards with 64-bit physical addressing
> instead of only doing it when highmem is set.

I think this should be fine. It only affects alchemy and Netlogic, and
Netlogic supports highmem already.

So for MIPS:
Acked-by: James Hogan <jhogan@kernel.org>

Cheers
James

> diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
> index 985388078872..e10cc5c7be69 100644
> --- a/arch/mips/Kconfig
> +++ b/arch/mips/Kconfig
> @@ -1101,9 +1101,6 @@ config GPIO_TXX9
>  config FW_CFE
>  	bool
> =20
> -config ARCH_DMA_ADDR_T_64BIT
> -	def_bool (HIGHMEM && PHYS_ADDR_T_64BIT) || 64BIT
> -
>  config ARCH_SUPPORTS_UPROBES
>  	bool

> diff --git a/lib/Kconfig b/lib/Kconfig
> index ce9fa962d59b..1f12faf03819 100644
> --- a/lib/Kconfig
> +++ b/lib/Kconfig
> @@ -435,6 +435,9 @@ config NEED_SG_DMA_LENGTH
>  config NEED_DMA_MAP_STATE
>  	bool
> =20
> +config ARCH_DMA_ADDR_T_64BIT
> +	def_bool 64BIT || PHYS_ADDR_T_64BIT
> +
>  config IOMMU_HELPER
>  	bool

--wzJLGUyc3ArbnUjN
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEARYIAB0WIQS7lRNBWUYtqfDOVL41zuSGKxAj8gUCWuo3DwAKCRA1zuSGKxAj
8tikAQDi/ZUNjW7+epg5yVcHFsdN4zPqszjMfOoZb9Tw0/w5/QD+O0gHySriLqfv
vZwnsvl5Mx2kzMLvdMNqFC++weR4XwQ=
=H1g4
-----END PGP SIGNATURE-----

--wzJLGUyc3ArbnUjN--
