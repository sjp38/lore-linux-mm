Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f177.google.com (mail-yw0-f177.google.com [209.85.161.177])
	by kanga.kvack.org (Postfix) with ESMTP id CCFD16B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 17:00:48 -0400 (EDT)
Received: by mail-yw0-f177.google.com with SMTP id g3so77312793ywa.3
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 14:00:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d194si1354468ybh.20.2016.03.16.14.00.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Mar 2016 14:00:48 -0700 (PDT)
Message-ID: <1458162041.14723.32.camel@redhat.com>
Subject: Re: [PATCH] mm: Export symbols unmapped_area() &
 unmapped_area_topdown()
From: Rik van Riel <riel@redhat.com>
Date: Wed, 16 Mar 2016 17:00:41 -0400
In-Reply-To: <20160316203657.GA29061@infradead.org>
References: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
	 <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com>
	 <20160316203657.GA29061@infradead.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-sGUCPP3aiXCKRFqnoKmT"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Olu Ogunbowale <Olu.Ogunbowale@imgtec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


--=-sGUCPP3aiXCKRFqnoKmT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-03-16 at 13:36 -0700, Christoph Hellwig wrote:
> On Wed, Mar 16, 2016 at 05:10:34PM +0000, Olu Ogunbowale wrote:
> >=20
> > From: Olujide Ogunbowale <Olu.Ogunbowale@imgtec.com>
> >=20
> > Export the memory management functions, unmapped_area() &
> > unmapped_area_topdown(), as GPL symbols; this allows the kernel to
> > better support process address space mirroring on both CPU and
> > device
> > for out-of-tree drivers by allowing the use of vm_unmapped_area()
> > in a
> > driver's file operation get_unmapped_area().
> No new exports without in-tree drivers.=C2=A0=C2=A0How about you get star=
ted
> to get your drives into the tree first?

The drivers appear to require the HMM framework though,
which people are also reluctant to merge without the
drivers.

How do we get past this chicken & egg situation?

--=20
All Rights Reversed.


--=-sGUCPP3aiXCKRFqnoKmT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJW6cl5AAoJEM553pKExN6DWIwH/01/Tm7vf4acX1zL3fGx7/qY
DM2gojo0pe6Ars5vDkIEtYVAW1X9stO1Xn/z1mFBY5BOsOn3xaZ/GyV+ls9E7mNe
cEPt05P9wrlMXfk9S378qlAZKe3S9YaxHe0mHOsHwIdbhCKSRc1wv2OaftWYvYXs
F7jGIvSA/jWsQAjLlmfVAkMPeP186367rZpmEurh9iioJZ+4kvVsKIWmcnB5UZEw
dOnbFarl9xrda76Kr6pIVwDxWc20cgP30jQSGWX5OzZQ89lBpSmih1Y8S/PzXoNo
a+0RiY/tJk8cWdX8gNrCaDAai+WE+UJpUcSgeS2q3ev9120bbdpGHmhM6Zo/jOM=
=jEtT
-----END PGP SIGNATURE-----

--=-sGUCPP3aiXCKRFqnoKmT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
