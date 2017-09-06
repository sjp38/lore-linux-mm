Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA18B28043E
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 18:32:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f4so135150wmh.7
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 15:32:08 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id l81si1234172wmf.31.2017.09.06.15.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Sep 2017 15:32:07 -0700 (PDT)
Date: Thu, 7 Sep 2017 00:32:06 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
Message-ID: <20170906223206.GA11481@amd>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
 <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
 <20170904162530.GA21781@amd>
 <20170905.144456.431070706382873486.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Content-Disposition: inline
In-Reply-To: <20170905.144456.431070706382873486.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: khalid.aziz@oracle.com, dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue 2017-09-05 14:44:56, David Miller wrote:
> From: Pavel Machek <pavel@ucw.cz>
> Date: Mon, 4 Sep 2017 18:25:30 +0200
>=20
> > Will gcc be able to compile code that uses these automatically? That
> > does not sound easy to me. Can libc automatically use this in malloc()
> > to prevent accessing freed data when buffers are overrun?
> >=20
> > Is this for benefit of JITs?
>=20
> Anything that can control mappings and the virtual address used to
> access memory can use ADI.
>=20
> malloc() is of course one such case.  It can map memory with ADI
> enabled, and return buffer addresses to malloc() callers with the
> proper virtual address bits set to satisfy the ADI key checks.
>=20
> And by induction anything using malloc() for it's memory allocation
> gets ADI protection as well.

I see; that's actually quite a nice trick.

I guess it does not protect against stack-based overflows, but should
help against heap-based overflows, so it improves security a bit, too.

Nice, thanks for explanation.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmwd2YACgkQMOfwapXb+vKZhQCghY433I84q+xJeU22IpRBNPMU
NLUAn2ZpOyO6CGTigbKV2RxaxhElPZ5X
=MKww
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
