Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 480786B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 10:14:44 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so51998663pab.3
        for <linux-mm@kvack.org>; Wed, 13 May 2015 07:14:44 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id gc5si19362503pac.51.2015.05.13.07.14.42
        for <linux-mm@kvack.org>;
        Wed, 13 May 2015 07:14:43 -0700 (PDT)
Date: Wed, 13 May 2015 10:14:42 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH 0/3] Allow user to request memory to be locked on page
 fault
Message-ID: <20150513141442.GC1227@akamai.com>
References: <1431113626-19153-1-git-send-email-emunson@akamai.com>
 <20150508124203.6679b1d35ad9555425003929@linux-foundation.org>
 <20150508200610.GB29933@akamai.com>
 <20150513135805.GA17708@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LwW0XdcUbUexiWVK"
Content-Disposition: inline
In-Reply-To: <20150513135805.GA17708@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--LwW0XdcUbUexiWVK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 13 May 2015, Michal Hocko wrote:

> On Fri 08-05-15 16:06:10, Eric B Munson wrote:
> > On Fri, 08 May 2015, Andrew Morton wrote:
> >=20
> > > On Fri,  8 May 2015 15:33:43 -0400 Eric B Munson <emunson@akamai.com>=
 wrote:
> > >=20
> > > > mlock() allows a user to control page out of program memory, but th=
is
> > > > comes at the cost of faulting in the entire mapping when it is
> > > > allocated.  For large mappings where the entire area is not necessa=
ry
> > > > this is not ideal.
> > > >=20
> > > > This series introduces new flags for mmap() and mlockall() that all=
ow a
> > > > user to specify that the covered are should not be paged out, but o=
nly
> > > > after the memory has been used the first time.
> > >=20
> > > Please tell us much much more about the value of these changes: the u=
se
> > > cases, the behavioural improvements and performance results which the
> > > patchset brings to those use cases, etc.
> > >=20
> >=20
> > The primary use case is for mmaping large files read only.  The process
> > knows that some of the data is necessary, but it is unlikely that the
> > entire file will be needed.  The developer only wants to pay the cost to
> > read the data in once.  Unfortunately developer must choose between
> > allowing the kernel to page in the memory as needed and guaranteeing
> > that the data will only be read from disk once.  The first option runs
> > the risk of having the memory reclaimed if the system is under memory
> > pressure, the second forces the memory usage and startup delay when
> > faulting in the entire file.
>=20
> Is there any reason you cannot do this from the userspace? Start by
> mmap(PROT_NONE) and do mmap(MAP_FIXED|MAP_LOCKED|MAP_READ|other_flags_you=
_need)
> from the SIGSEGV handler?
> You can generate a lot of vmas that way but you can mitigate that to a
> certain level by mapping larger than PAGE_SIZE chunks in the fault
> handler. Would that work in your usecase?

This might work for the use cases I have laid out (I am not sure about
the anonymous mmap one, but I will try it).  I am concerned about how
much memory management policy these suggestions push into userspace.
I am also concerned about the number of system calls required to do the
same thing.  This will require a new call to mmap() for every new page
accessed in the file (or for every file_size/map_size in the multiple
page chunk).  The simple case of calling mlock() on the every time the
file was accessed was significantly slower than the LOCKONFAULT flag.
Your suggestion will be better in that it avoids the extra mlock call
for pages already locked, but there still significantly more system
calls.  I will add this to the program I have been using to measure
executuion times and see how it compares to the other options.

Eric


--LwW0XdcUbUexiWVK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVU1xSAAoJELbVsDOpoOa9ST0QALjeZMUC+/sOsLGgTFLfO0x9
u6Bh2+sOR/Uba5bSaP4rYLlsfWGTD++9R3fV2yZJ9gQKGZaDm7fZOZXbaoQhjZLL
/XwF6jnPyknimsgIMrqRf6j9RJQvJjl3ruRheA0W690BAPkBV6R40Bu6UW0X/7vx
wMWR+3cLg5uJ80N1xxNVh2KkBezWtRKjfAueqMdIPcrXBz80xN8dnA0fdkN2Wpnp
4CwbcYSg87W2/v0sdyiBrgIKca73Ic1/o7mv6O5isxViwd983SzKr1qn+FXAPTJc
R66It0tG7mmZ/kIDVrCOXZY0Fme6WiK0wiImxXNZifjDkDo5Pko1Ng+MjJehyYhL
Z/S4xy6jcQD++Ih2B95iAilK/8ZzP9mja8Wo6dhN+l/AlQdvSINULfXgi+9BnngY
zMMUXGOEwIGAkxHWqh8iGTb7gjy7iPWTqqb06soQFq2Ol8uzFQpwEnKV1pCZG3PO
+Wp7oqGZraI5ckiw6M4+6auXWjOgcU2Uvf+82vCRbC1/8VHHEnN088fr9+f9wSBP
TG2JO08lQTGIF1VvwYqfEsnWRvez+CQwr+sVIs1VXqvDiS694RZlT2FHLK/6USoF
vn8WmBMJDissA3A0jgn9zIaTq393K27pFuc96zAsI4LYMLEZguYlkPT148GRJoXO
bjOom+hb4Q4khMm9zqtk
=Hfxi
-----END PGP SIGNATURE-----

--LwW0XdcUbUexiWVK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
