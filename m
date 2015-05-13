Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 69AA36B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 11:00:38 -0400 (EDT)
Received: by pdea3 with SMTP id a3so54110106pde.3
        for <linux-mm@kvack.org>; Wed, 13 May 2015 08:00:38 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id or3si27470975pdb.190.2015.05.13.08.00.37
        for <linux-mm@kvack.org>;
        Wed, 13 May 2015 08:00:37 -0700 (PDT)
Date: Wed, 13 May 2015 11:00:36 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH 0/3] Allow user to request memory to be locked on page
 fault
Message-ID: <20150513150036.GG1227@akamai.com>
References: <1431113626-19153-1-git-send-email-emunson@akamai.com>
 <20150508124203.6679b1d35ad9555425003929@linux-foundation.org>
 <20150511180631.GA1227@akamai.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="df+09Je9rNq3P+GE"
Content-Disposition: inline
In-Reply-To: <20150511180631.GA1227@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--df+09Je9rNq3P+GE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 11 May 2015, Eric B Munson wrote:

> On Fri, 08 May 2015, Andrew Morton wrote:
>=20
> > On Fri,  8 May 2015 15:33:43 -0400 Eric B Munson <emunson@akamai.com> w=
rote:
> >=20
> > > mlock() allows a user to control page out of program memory, but this
> > > comes at the cost of faulting in the entire mapping when it is
> > > allocated.  For large mappings where the entire area is not necessary
> > > this is not ideal.
> > >=20
> > > This series introduces new flags for mmap() and mlockall() that allow=
 a
> > > user to specify that the covered are should not be paged out, but only
> > > after the memory has been used the first time.
> >=20
> > Please tell us much much more about the value of these changes: the use
> > cases, the behavioural improvements and performance results which the
> > patchset brings to those use cases, etc.
> >=20
>=20
> To illustrate the proposed use case I wrote a quick program that mmaps
> a 5GB file which is filled with random data and accesses 150,000 pages
> from that mapping.  Setup and processing were timed separately to
> illustrate the differences between the three tested approaches.  the
> setup portion is simply the call to mmap, the processing is the
> accessing of the various locations in  that mapping.  The following
> values are in milliseconds and are the averages of 20 runs each with a
> call to echo 3 > /proc/sys/vm/drop_caches between each run.
>=20
> The first mapping was made with MAP_PRIVATE | MAP_LOCKED as a baseline:
> Startup average:    9476.506
> Processing average: 3.573
>=20
> The second mapping was simply MAP_PRIVATE but each page was passed to
> mlock() before being read:
> Startup average:    0.051
> Processing average: 721.859
>=20
> The final mapping was MAP_PRIVATE | MAP_LOCKONFAULT:
> Startup average:    0.084
> Processing average: 42.125
>=20

Michal's suggestion of changing protections and locking in a signal
handler was better than the locking as needed, but still significantly
more work required than the LOCKONFAULT case.

Startup average:    0.047
Processing average: 86.431


--df+09Je9rNq3P+GE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVU2cUAAoJELbVsDOpoOa9baQQANJIi9hDC0B5PmZg1n740+8X
5w7lzvAiDqRYi4/xYMjtx55l9M/YpTlnEuCPHUjEUvQvpxALWGSTYmcJ6cNx47Gh
/BHWrTr4oedPg23icayje+QC/DKF10OT/qBx/ep/+J4nEEZnbBQmk5Ce2EbjVCDm
4Xs3RjSeD9cWAOoHTsN2oqerZSM+DlqGU0Q2mWu10VM6usItc1oWk6U/gpD/26tE
lfMslp8jsECGvLmd4Zkj44HifD36pI0InaSKeBLrUCAe8W6qvhCuIaKRdOn00lgZ
CcUfQsK0c/7aYOZDm5CM4EUm+F8ee0mJV19qDMOm5rU9IrFZ4zj6rzRUHQ5OHcFH
mLxWm6wtqxYSapbWkYhiMei6lzDeMi0aL9BHKnzktgABBO1rwgNwPTlmwIWZcyPz
GWtxOw2oQZ6NqfGp9p3s677z2yicYQEJtEsvGrj5RVCUiXOwcRbQ0qNn8hF/6DrV
Xpk/cL6Zr9g8Klh/tLSN1CTXkcvGU6Poc83MLqf7DWmoKB86izb6MLoV4l5ckfyQ
s3nDQ6IJHOM3LaHIxeHj3FjHABx/lzwN22sKeRhsDduqiYUq3Y0i2J39ujXbZeUl
VlZ37T447uyO+nDgvg27P4MVsQlYYqt/vMmZ/a1NJdDXkzQU5RYpEmIeX/Z1Rifz
2Mean0e41gkDsd0BkxJb
=mszX
-----END PGP SIGNATURE-----

--df+09Je9rNq3P+GE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
