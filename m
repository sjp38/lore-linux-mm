From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
Date: Mon, 4 Sep 2017 18:25:30 +0200
Message-ID: <20170904162530.GA21781@amd>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
 <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
Sender: linux-doc-owner@vger.kernel.org
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: davem@davemloft.net, dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@
List-Id: linux-mm.kvack.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> ADI is a new feature supported on SPARC M7 and newer processors to allow
> hardware to catch rogue accesses to memory. ADI is supported for data
> fetches only and not instruction fetches. An app can enable ADI on its
> data pages, set version tags on them and use versioned addresses to
> access the data pages. Upper bits of the address contain the version
> tag. On M7 processors, upper four bits (bits 63-60) contain the version
> tag. If a rogue app attempts to access ADI enabled data pages, its
> access is blocked and processor generates an exception. Please see
> Documentation/sparc/adi.txt for further details.

I'm afraid I still don't understand what this is meant to prevent.

IOMMU ignores these, so this is not to prevent rogue DMA from doing
bad stuff.

Will gcc be able to compile code that uses these automatically? That
does not sound easy to me. Can libc automatically use this in malloc()
to prevent accessing freed data when buffers are overrun?

Is this for benefit of JITs?

Thanks,

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmtfnoACgkQMOfwapXb+vIj2gCfXiURelq6uzm0dsURRHOWTiMf
/CAAoJhH1YhBiREIJdoEyCHXwW7lc7LE
=WGuR
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--
