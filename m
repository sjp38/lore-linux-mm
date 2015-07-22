Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id D8B106B0256
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:32:21 -0400 (EDT)
Received: by qged69 with SMTP id d69so74166174qge.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:32:21 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id p75si1832173qgp.114.2015.07.22.07.32.20
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 07:32:21 -0700 (PDT)
Date: Wed, 22 Jul 2015 10:32:20 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V4 5/6] mm: mmap: Add mmap flag to request VM_LOCKONFAULT
Message-ID: <20150722143220.GB3203@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-6-git-send-email-emunson@akamai.com>
 <20150722112558.GC8630@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eJnRUKwClWJh1Khz"
Content-Disposition: inline
In-Reply-To: <20150722112558.GC8630@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Paul Gortmaker <paul.gortmaker@windriver.com>, Chris Metcalf <cmetcalf@ezchip.com>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--eJnRUKwClWJh1Khz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 22 Jul 2015, Kirill A. Shutemov wrote:

> On Tue, Jul 21, 2015 at 03:59:40PM -0400, Eric B Munson wrote:
> > The cost of faulting in all memory to be locked can be very high when
> > working with large mappings.  If only portions of the mapping will be
> > used this can incur a high penalty for locking.
> >=20
> > Now that we have the new VMA flag for the locked but not present state,
> > expose it as an mmap option like MAP_LOCKED -> VM_LOCKED.
>=20
> What is advantage over mmap() + mlock(MLOCK_ONFAULT)?

There isn't one, it was added to maintain parity with the
mlock(MLOCK_LOCK) -> mmap(MAP_LOCKED) set.  I think not having will lead
to confusion because we have MAP_LOCKED so why don't we support
LOCKONFAULT from mmap as well.


--eJnRUKwClWJh1Khz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVr6l0AAoJELbVsDOpoOa98fUQANDd9dNcrulIgLSf+ajZqiUo
50UtNRMATvsiEBAEyJ8CwGzwUBQIYwHDU9LU28NUSZCgYJpGiN+PmJ61ZaU3f63x
Wps5ZlPg1MvY/IbHLmYTMD6UiXPa7zsAjTFNA6Fi0MwCjyLphtK6jqf8EhsoOLSo
YFsTccyuOfqJrbk/fXi3ioNPFVIkHpwNcdL1+sYOJf3Wkf8FBBnlvEMnOSmtw7GC
Uont1PBKFNeUNmk/sxxLDgJ0vwMx09sjfjYX+8ZOxS0E1JjeflHTSITsPeWt2/AI
0Qm0lxu0bZ62nnt8zvBVcCAoImIjFNgNnqxQwfKfb5kYgiR0c8ZSyOOuiGxugwI/
TKBkVU/e34Xc43UkmnseBl8SFUW1tF5eLLIvFt1apJ8ygrr4M4uIJIQV4UMSNVLG
VEV5c08dN91BRjDesU3EJ1vtPXK6avkZokkbNWmeoIQ70wOD2KSJurs0t5dFLtBw
t8t27CTYo/Fpg9kyLsgHzTqf4cH+L0FqVHJ4oQNU2OZvwvW5odyztgDdQV9KhEvf
k/MNlOTNpD8idmgCBSpVeReKAWkQEwRaB5QZWP9X4axdR6r7HwGvV3lWbwBpwa5i
LksIegF8VdBCnD8SibMXl37buy8oPlop5arIjvRHi8VMz6AhRK9OH1T/Mn0+yAIy
yBmHM0EALawWdDffUN1r
=GpJe
-----END PGP SIGNATURE-----

--eJnRUKwClWJh1Khz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
