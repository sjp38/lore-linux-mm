Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 7AB726B00EB
	for <linux-mm@kvack.org>; Sat, 26 May 2012 17:38:04 -0400 (EDT)
Message-ID: <1338068260.20487.35.camel@deadeye>
Subject: Re: Please include commit 90481622d7 in 3.3-stable
From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 26 May 2012 22:37:40 +0100
In-Reply-To: <1336811645.8274.496.camel@deadeye>
References: <20120510095837.GB16271@bloggs.ozlabs.ibm.com>
	 <1336811645.8274.496.camel@deadeye>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ooOyusrTxo3clQ67+tbu"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Gibson <david@gibson.dropbear.id.au>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org


--=-ooOyusrTxo3clQ67+tbu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-05-12 at 09:34 +0100, Ben Hutchings wrote:
> On Thu, 2012-05-10 at 19:58 +1000, Paul Mackerras wrote:
> > Please include commit 90481622d7 ("hugepages: fix use after free bug
> > in "quota" handling") from Linus' tree in the next 3.3 stable release.
> > It applies without fuzz, though with offsets.
> >=20
> > It fixes a use-after-free bug in the huge page code that we are
> > hitting when using KVM on IBM Power machines with large pages backing
> > the guests, though it can in principle be hit in other ways also.
> > Since it's a use-after-free bug, it tends to result in an immediate
> > kernel crash if you have slab debug turned on, or occasional
> > hard-to-debug memory corruption if you don't.
> >=20
> > The bug is also present in earlier kernels, and the patch should
> > apply at least to 3.2.  It would be good if it can be applied to
> > earlier kernels also.
>=20
> I tried cherry-picking this on top of 3.2.17, but there was a conflict
> in unmap_ref_private().  It looks like all of these belong in 3.2.y as
> well:
>=20
> 1e16a53 mm/hugetlb.c: fix virtual address handling in hugetlb fault
> 0c176d5 mm: hugetlb: fix pgoff computation when unmapping page from vma
> ea5768c mm/hugetlb.c: avoid bogus counter of surplus huge page
> 409eb8c mm/hugetlb.c: undo change to page mapcount in fault handler
> cd2934a flush_tlb_range() needs ->page_table_lock when ->mmap_sem is not =
held

Sorry, I didn't make myself clear.  I'm asking for confirmation: should
these all be applied to 3.2.y?

Ben.

--=20
Ben Hutchings
You can't have everything.  Where would you put it?

--=-ooOyusrTxo3clQ67+tbu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT8FNJOe/yOyVhhEJAQpOHQ/6AlODr6bV2U8/CrJLT87ow1xcLFi8rMTX
isKFUCdPIGgw2W8Wej0J9pJL3gowa83EJwNvNdePfguVW2Q6fkeQbchs4/O+eK8K
dtuu61le65fKjFTktTGghHysKc+VKSTY5cgiuyde54iZvyzXPR4ryzBga7n812WH
gpRWEQh/mFEYuiQvimel6MfEqsPv6L0pMg2UScYgQuL9nybFSxXC60pAu+yJ2scu
zV9K1CJ7X2dslZ67KzEa7l6IFtLEBOUbnFKyZMZbCKAI0Bw8GS424sfMBbSVyMzB
nhvP6Wcz8mvisOHqA+zJthm4O9IzNLzlZKiqB9G85Gyd0tKs/C219+CjImLpcT1a
jyBr6hQAZ2bJvIZsqMQvwJXJiQk+KbecEhk/Ftbh4bv6UwLSP6KzfLdtN8IDVaXq
O12A2Z65upSv2JyoHfbhGNHOoyPi5Cp3vyY8s9VqICUaOQCJmjrj35TPWnclvpOu
oV1GYo+9X1ASiVi4O1eIyD/tAwCOoTf2wMNG3/CxScGMMmxdnipGOVDAJt7xxJTi
3KLS8eMfsySI34zPmXk/DHZlp3gV5OXDscONsdhPfvEDqUPSIg6nhvdQS+4oOWv9
jarxDWu9XV2SY3OlNSk3ZHrg82+oKwyKToRS1nUQvEykKyTqW7XG/pkc7ofrn9c2
vRBUwHJspSI=
=9jP1
-----END PGP SIGNATURE-----

--=-ooOyusrTxo3clQ67+tbu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
