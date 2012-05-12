Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 4A2746B004D
	for <linux-mm@kvack.org>; Sat, 12 May 2012 04:34:32 -0400 (EDT)
Message-ID: <1336811645.8274.496.camel@deadeye>
Subject: Re: Please include commit 90481622d7 in 3.3-stable
From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 12 May 2012 09:34:05 +0100
In-Reply-To: <20120510095837.GB16271@bloggs.ozlabs.ibm.com>
References: <20120510095837.GB16271@bloggs.ozlabs.ibm.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tjIj8r+udfFg/jnNsWzQ"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Gibson <david@gibson.dropbear.id.au>
Cc: stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org


--=-tjIj8r+udfFg/jnNsWzQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-05-10 at 19:58 +1000, Paul Mackerras wrote:
> Please include commit 90481622d7 ("hugepages: fix use after free bug
> in "quota" handling") from Linus' tree in the next 3.3 stable release.
> It applies without fuzz, though with offsets.
>=20
> It fixes a use-after-free bug in the huge page code that we are
> hitting when using KVM on IBM Power machines with large pages backing
> the guests, though it can in principle be hit in other ways also.
> Since it's a use-after-free bug, it tends to result in an immediate
> kernel crash if you have slab debug turned on, or occasional
> hard-to-debug memory corruption if you don't.
>=20
> The bug is also present in earlier kernels, and the patch should
> apply at least to 3.2.  It would be good if it can be applied to
> earlier kernels also.

I tried cherry-picking this on top of 3.2.17, but there was a conflict
in unmap_ref_private().  It looks like all of these belong in 3.2.y as
well:

1e16a53 mm/hugetlb.c: fix virtual address handling in hugetlb fault
0c176d5 mm: hugetlb: fix pgoff computation when unmapping page from vma
ea5768c mm/hugetlb.c: avoid bogus counter of surplus huge page
409eb8c mm/hugetlb.c: undo change to page mapcount in fault handler
cd2934a flush_tlb_range() needs ->page_table_lock when ->mmap_sem is not he=
ld

Ben.

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-tjIj8r+udfFg/jnNsWzQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT64gfee/yOyVhhEJAQqf+RAAma8ul7zgC7g7JQOjDSfaNQvwSmeGIxkA
UTTrRhDEMpxiqEIBdf0eo2fRB8fLYsn/11GN68LqEsXWgOTNqXyqhiHCBjSRTF8b
KvkF/npc79AtRpXO4fBdDS1iqIXOnT0DWHaKBeiYIckCME+BfNyB1fqWAFXfAlET
XO9pXI/kuujAOeAFU0Hbcgw+wbowI/Kmu3M2tFheKqFqZ4Hv+VFAj2MvslyveNLV
Xd5Mc08WZXPtZh8YLKToWwSL/Sm/hcEtpGaXAU/9SwgHF+fmZCtnl/Tew1ic4/LV
fgSjmDAU5qhj8kTugNPazcBLKMmjP2bVUiA+2v0OyzTJPLYMDcaYyQajN5kGfI85
oU6a7oRnqdU+tfip7NCkcykgSIhSlMQJenGKs6/Ns1CoEWZQ3ja+MIxTtNI5GgAj
wBZmwFvFyz71qkxNCVukpr98Wbb3rPeqhFvff+VzpwpbZW3ZtnQMZj6d9wnDjZJI
VGXiYkN78MycDiSQGkYRrgNaYtHYA6p5Z+0HyEh4jtBzjPASNdmkRb99hZIldgJv
+4nlYExRdawFnqX2e7SczgErQbya4dUAuRJan81Mmc1INNfQcp1mi2aOqvi5RAjJ
JtSIXOXjnWihr21VZo+qtADnmPRQZasQeksej7c9PqgrLNS0ancXI3cpgfkLq00j
YtlyONiCPFU=
=LG8g
-----END PGP SIGNATURE-----

--=-tjIj8r+udfFg/jnNsWzQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
