Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id C15676B0096
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 17:04:28 -0500 (EST)
Date: Thu, 13 Dec 2012 00:05:05 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 09/11] thp: lazy huge zero page allocation
Message-ID: <20121212220505.GA24391@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-10-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141535190.22537@chino.kir.corp.google.com>
 <20121115094155.GG9676@otc-wbsnb-06>
 <20121212133051.6dad3722.akpm@linux-foundation.org>
 <50C8FB94.6050209@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Content-Disposition: inline
In-Reply-To: <50C8FB94.6050209@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 12, 2012 at 01:48:04PM -0800, H. Peter Anvin wrote:
> On 12/12/2012 01:30 PM, Andrew Morton wrote:
> >>
> >> I can rewrite the check to static_key if you want. Would it be better?
> >=20
> > The new test-n-branch only happens on the first read fault against a
> > thp huge page, yes?  In which case it's a quite infrequent event and I
> > suspect this isn't worth bothering about.
> >=20
>=20
> Not to mention that flipping the static key is *incredibly* expensive.

I'm fine with current code.

--=20
 Kirill A. Shutemov

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQyP+RAAoJEAd+omnVudOMa90QALBZOAUjaliAIrj0hqiEd5Sk
RmyTE20WVt2iJE9uqwIoreb2gjzKkzRHQOydkuSgBZNt9VatO0IA+OEkNabpj9fZ
/lp+H183t36QIuLGnrVeRVo5T70/2fsUak7BfrErl6km7GK6GckdzpWWmDNww+Mj
qto5iVpDl1I/a74kOtw07kXo4N2omLJGwNmBXjj4JBZTG+oSqftJ25utwt6FvdKR
KxdSjNqP8BZjFG9bCpYzglQsJemoQ8TS8MHmZbM+C9EbZf4vC4RCPF8Bh1MUgSfB
wfRoyYPKD10hk2vUyMcz3fP/GwnBsIFdBc2Q1egZDOHzFMhESB8wRjdQjX2lzUBP
KVgumRkA4gqFBqX3YGComAqO4NC29bc4KXua2273KOD6KGXaV1Ub3tncNQwnbXFT
yGHhj21JjGoOPbaujA68F6aeMhUYrcwaZhQKIO+m82s0ugkYfO/HXjx6gMGOQW2L
TY1km/mEb0D34pq/L8de4fZPBt30moP4IQ30JdfenXMPTuvUwGcD6HtpimKtasWb
6LQvIeXZp4SZdkJ+iOOAJCTPrj39ghBNctSvno28pOSJWONx4gRy1YAbcq74UPJw
sxH3JgfApoQ68TrDCXHCnpEoIZurpiEJF7UVYia9Xj7BkVmUWqBdT2nJe4q6WgGi
zIE3gnh9sr2Dcg299Oc1
=8qpu
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
