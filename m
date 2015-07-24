Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2946A6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:39:38 -0400 (EDT)
Received: by qged69 with SMTP id d69so11545351qge.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:39:38 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id b34si10268486qkb.72.2015.07.24.07.39.36
        for <linux-mm@kvack.org>;
        Fri, 24 Jul 2015 07:39:37 -0700 (PDT)
Date: Fri, 24 Jul 2015 10:39:36 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V4 2/6] mm: mlock: Add new mlock, munlock, and munlockall
 system calls
Message-ID: <20150724143936.GE9203@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-3-git-send-email-emunson@akamai.com>
 <20150721134441.d69e4e1099bd43e56835b3c5@linux-foundation.org>
 <1437528316.16792.7.camel@ellerman.id.au>
 <20150722141501.GA3203@akamai.com>
 <20150723065830.GA5919@linux-mips.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+JUInw4efm7IfTNU"
Content-Disposition: inline
In-Reply-To: <20150723065830.GA5919@linux-mips.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf Baechle <ralf@linux-mips.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mips@linux-mips.org, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-am33-list@redhat.com, Geert Uytterhoeven <geert@linux-m68k.org>, Vlastimil Babka <vbabka@suse.cz>, Guenter Roeck <linux@roeck-us.net>, linux-xtensa@linux-xtensa.org, linux-s390@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-parisc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org


--+JUInw4efm7IfTNU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 23 Jul 2015, Ralf Baechle wrote:

> On Wed, Jul 22, 2015 at 10:15:01AM -0400, Eric B Munson wrote:
>=20
> > >=20
> > > You haven't wired it up properly on powerpc, but I haven't mentioned =
it because
> > > I'd rather we did it.
> > >=20
> > > cheers
> >=20
> > It looks like I will be spinning a V5, so I will drop all but the x86
> > system calls additions in that version.
>=20
> The MIPS bits are looking good however, so
>=20
> Acked-by: Ralf Baechle <ralf@linux-mips.org>
>=20
> With my ack, will you keep them or maybe carry them as a separate patch?

I will keep the MIPS additions as a separate patch in the series, though
I have dropped two of the new syscalls after some discussion.  So I will
not include your ack on the new patch.

Eric

--+JUInw4efm7IfTNU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVsk4oAAoJELbVsDOpoOa9Eo0QAJ6eViChMf3Imw2HLUBOL+qS
B7hozSCTuKLHaqx8QBhkjX6yqn0FIa5+TUWk76Py3JA00geQAiSWGmmZidLmdkmL
QqZgrvi6B/hsDx4qhNk3wsTpeOtRL6JfpM0CI42Y5JO9nXvp/mpEJyHIRbrvlOtG
GdRPYjyf1gXqwFaOJel7/GvPhRxMh0vkIr78XqNZOQovWL9cfvaUGaZmLGcLJq78
PPYyuZ53AmNg83C8wDpgPfdgQ/L4ob+mZJIcP8purUXHpu7Xu7KbePkdoPqZ1EDT
zRias9nrfrQQTCYaga4MM6wMa2S+iDNPq6Ae+sI6eoDyMxhjuUEi4xxHZ9HGwSIm
Ii5cbD5//xbOHceAPuQ0lhvWH06ip6OVEXx68ACl7p46Ebi7B2jOeSyKH3UNpomS
37NdAdUk3PlC3r3CwoPS2XXYjthQr8rVLVqoZP1wC4KxHanglXzFv+AwyLwRCQJ3
6WevOpUmjVstR67EZBXmHMC4yVGxwF9TdC15G4coZEBw8wcLV6rC2TuK1KZw5JHR
1yIJtZIBQmNoFkGwNWggIFsDiOasKmgUjjHY/yPPrn0MTkCy69zrnkqzoKZQEIoE
MXYJiYfYFy7Ek7/K7u/lCjJI0X1bXk3QTmNrX5BuVzQPtV8jdzcBzl4SQhFGc7IH
4GNpeBolyRBy2p7wt0lO
=/Udu
-----END PGP SIGNATURE-----

--+JUInw4efm7IfTNU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
