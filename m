Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id DA4356B0254
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:53:14 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so16744841qkb.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 08:53:14 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id a22si10523832qka.78.2015.07.24.08.53.13
        for <linux-mm@kvack.org>;
        Fri, 24 Jul 2015 08:53:14 -0700 (PDT)
Date: Fri, 24 Jul 2015 11:53:13 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V4 2/6] mm: mlock: Add new mlock, munlock, and munlockall
 system calls
Message-ID: <20150724155313.GF9203@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-3-git-send-email-emunson@akamai.com>
 <20150721134441.d69e4e1099bd43e56835b3c5@linux-foundation.org>
 <1437528316.16792.7.camel@ellerman.id.au>
 <20150722141501.GA3203@akamai.com>
 <20150723065830.GA5919@linux-mips.org>
 <20150724143936.GE9203@akamai.com>
 <55B25DDE.8090107@roeck-us.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="iBwuxWUsK/REspAd"
Content-Disposition: inline
In-Reply-To: <55B25DDE.8090107@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Ralf Baechle <ralf@linux-mips.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mips@linux-mips.org, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-am33-list@redhat.com, Geert Uytterhoeven <geert@linux-m68k.org>, Vlastimil Babka <vbabka@suse.cz>, linux-xtensa@linux-xtensa.org, linux-s390@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-parisc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org


--iBwuxWUsK/REspAd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 24 Jul 2015, Guenter Roeck wrote:

> On 07/24/2015 07:39 AM, Eric B Munson wrote:
> >On Thu, 23 Jul 2015, Ralf Baechle wrote:
> >
> >>On Wed, Jul 22, 2015 at 10:15:01AM -0400, Eric B Munson wrote:
> >>
> >>>>
> >>>>You haven't wired it up properly on powerpc, but I haven't mentioned =
it because
> >>>>I'd rather we did it.
> >>>>
> >>>>cheers
> >>>
> >>>It looks like I will be spinning a V5, so I will drop all but the x86
> >>>system calls additions in that version.
> >>
> >>The MIPS bits are looking good however, so
> >>
> >>Acked-by: Ralf Baechle <ralf@linux-mips.org>
> >>
> >>With my ack, will you keep them or maybe carry them as a separate patch?
> >
> >I will keep the MIPS additions as a separate patch in the series, though
> >I have dropped two of the new syscalls after some discussion.  So I will
> >not include your ack on the new patch.
> >
> >Eric
> >
>=20
> Hi Eric,
>=20
> next-20150724 still has some failures due to this patch set. Are those
> being looked at (I know parisc builds fail, but there may be others) ?
>=20
> Thanks,
> Guenter

Guenter,

Yes, the next respin will drop all new arch syscall entries except
x86[_64] and MIPS.  I will leave it up to arch maintainers to add the
entries.

Eric

--iBwuxWUsK/REspAd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVsl9pAAoJELbVsDOpoOa9EEUP/2M1Xsm8+njDOkkKbV0gBjBz
b3xOA+mBrdWvRUHtbhky0XhLX9AQkuolm5Lqel2ldbkHMF2DQtqvQxMCpWJ25dJW
oR5fnuh+arfoOsnEJAJ4Z47Qs/jiVAWHB3jupCxexg5zVZL2BIomII5Ewk00waGw
zHjUYeLYPTn6IE1MWV1Mlbbx+kGCDRz8HgFq8b3WbrgH4pPzqaeSf3wxMnIYVKuL
D/vyOdBOE0dW0Co4GdA3iqZ0JGSKknZUP/F3xB/z67wCkIjh133cUI3oDL/4MKbU
vSac0mG99uhmMPii1kWKyF3OVx3flbHo4IPFDAaUfU1O1OAXHvjezBgL3eLEV3xl
M/BZQZMEGNZjs6+c8oIrFuEvKDc424HRj7bKbBRvv7rXp3oaksyvuJ3mpEJyEhep
O+pSxjZc5J9QaXer+Rdh3yX/hjM/dpnTsUPXTIgPlJcIS8gSc5GxrCOe1hQD7u08
lIxdAs3sI5Tn6iwrjDRq1ySz2NZ2LkfBlliZ41xxt8/kzHvPoieeep2DRDJnpqJG
nyQItitQpzs0vB7UMJV+yrbfSAR+lupvVdfyXjk8fsYPMNPBhWHQKZ6Ky6euTkYs
/BWwZ2nvEjopIBEdrXJ97jJcjsAstFCnCm8V75JOX9KznfD0OUNCB6bg9UpUYQfX
IV8UQYGPDzfVm060LKYD
=SPSa
-----END PGP SIGNATURE-----

--iBwuxWUsK/REspAd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
