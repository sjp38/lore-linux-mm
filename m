Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 901C66B0006
	for <linux-mm@kvack.org>; Wed,  2 May 2018 18:20:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z10so13953037pfm.2
        for <linux-mm@kvack.org>; Wed, 02 May 2018 15:20:27 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c23-v6si11716233plo.80.2018.05.02.15.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 15:20:26 -0700 (PDT)
Date: Wed, 2 May 2018 23:20:18 +0100
From: James Hogan <jhogan@kernel.org>
Subject: Re: [PATCH 11/13] mips,unicore32: swiotlb doesn't need sg->dma_length
Message-ID: <20180502222017.GC20766@jamesdev>
References: <20180425051539.1989-1-hch@lst.de>
 <20180425051539.1989-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Izn7cH1Com+I3R9J"
Content-Disposition: inline
In-Reply-To: <20180425051539.1989-12-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org, sstabellini@kernel.org, x86@kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org


--Izn7cH1Com+I3R9J
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Wed, Apr 25, 2018 at 07:15:37AM +0200, Christoph Hellwig wrote:
> Only mips and unicore32 select CONFIG_NEED_SG_DMA_LENGTH when building
> swiotlb.  swiotlb itself never merges segements and doesn't accesses the
> dma_length field directly, so drop the dependency.

Is that at odds with Documentation/DMA-API-HOWTO.txt, which seems to
suggest arch ports should enable it for IOMMUs?

Cheers
James

--Izn7cH1Com+I3R9J
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEARYIAB0WIQS7lRNBWUYtqfDOVL41zuSGKxAj8gUCWuo5nwAKCRA1zuSGKxAj
8toFAQDILXOi2KhP1yoO3zabIiof3I/tmRomgzUgGA3ESVm5lgEA4elhmn7zDXhX
YG33reqJ7xyPenaOF8AX63cB5eqjOQ8=
=UDV2
-----END PGP SIGNATURE-----

--Izn7cH1Com+I3R9J--
