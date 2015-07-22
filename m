Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5DCBF9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:15:03 -0400 (EDT)
Received: by qkdl129 with SMTP id l129so153901470qkd.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:15:03 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id e131si1775165qhc.88.2015.07.22.07.15.02
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 07:15:02 -0700 (PDT)
Date: Wed, 22 Jul 2015 10:15:01 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V4 2/6] mm: mlock: Add new mlock, munlock, and munlockall
 system calls
Message-ID: <20150722141501.GA3203@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-3-git-send-email-emunson@akamai.com>
 <20150721134441.d69e4e1099bd43e56835b3c5@linux-foundation.org>
 <1437528316.16792.7.camel@ellerman.id.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Content-Disposition: inline
In-Reply-To: <1437528316.16792.7.camel@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mips@linux-mips.org, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-am33-list@redhat.com, Geert Uytterhoeven <geert@linux-m68k.org>, Vlastimil Babka <vbabka@suse.cz>, Guenter Roeck <linux@roeck-us.net>, linux-xtensa@linux-xtensa.org, linux-s390@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-parisc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 22 Jul 2015, Michael Ellerman wrote:

> On Tue, 2015-07-21 at 13:44 -0700, Andrew Morton wrote:
> > On Tue, 21 Jul 2015 15:59:37 -0400 Eric B Munson <emunson@akamai.com> w=
rote:
> >=20
> > > With the refactored mlock code, introduce new system calls for mlock,
> > > munlock, and munlockall.  The new calls will allow the user to specify
> > > what lock states are being added or cleared.  mlock2 and munlock2 are
> > > trivial at the moment, but a follow on patch will add a new mlock sta=
te
> > > making them useful.
> > >=20
> > > munlock2 addresses a limitation of the current implementation.  If a
> > > user calls mlockall(MCL_CURRENT | MCL_FUTURE) and then later decides
> > > that MCL_FUTURE should be removed, they would have to call munlockall=
()
> > > followed by mlockall(MCL_CURRENT) which could potentially be very
> > > expensive.  The new munlockall2 system call allows a user to simply
> > > clear the MCL_FUTURE flag.
> >=20
> > This is hard.  Maybe we shouldn't have wired up anything other than
> > x86.  That's what we usually do with new syscalls.
>=20
> Yeah I think so.
>=20
> You haven't wired it up properly on powerpc, but I haven't mentioned it b=
ecause
> I'd rather we did it.
>=20
> cheers

It looks like I will be spinning a V5, so I will drop all but the x86
system calls additions in that version.

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVr6VlAAoJELbVsDOpoOa95lcP/09wvimQwXtTG/OgMLsgEPaz
FVL4uSMeiSaPdcdYp1Qp+ie80X/Ve92le8uJ9pcRKV3+cK2xP8OiOQQQwz57cBU8
MIzkJPycm2gww6DRwYVjXhUJH2FMb1KK1vQALVWwh0mUAkRvpi4T7mtxSzmRUD+V
TEw4dIBmK3dEorWA7duy9L/8juLu/j2kd3GzFnd5vp7q5HDb+tJrBD+I1jos2dlQ
KqYzU5vCmPC11pc2TzzFkXx6hGux1Rj4y/7jUMID14Hi+Ql0dQGwMo6kcMmdxS+P
kULToMPhnlDZIAfNOpfanHUsnzLPy4UVJ2ecYHXte7Yj4uxU9NXf6Dli47/iZK4H
lp+MUwmXEQsoQTqwUWO36Hcpu5aKHQzbmz3qeNwLe37ZauHahT7GSYR8ZrntQo2v
oQs9zdeLt2enFwC0QSubvRtIAEbpvnWvup0lD89fEFMubri6IFKFFMuSIr9kNBS0
6jcxjzbH03cDgnrlAEb0k54nblsgCRoagmHpqZH+TzAKlLqUXpIeqVUnkjXrclkg
XBlxVwh2m0LvFFWnTZ/AoXmZif91GBNQw+ZPkju+iRs8r3YtjH3Pv2aZL4tjDFzA
/Gyv+WSvZ3NjakBejr+qzZiET/MSEmX1agUJo/2sd0QUL/z0Jk1gConPgmjaoFCO
UoTgStn2fZdwMTcy6Lyt
=nv7P
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
