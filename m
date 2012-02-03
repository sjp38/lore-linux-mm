Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 402746B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 05:29:10 -0500 (EST)
From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [RESEND][PATCH] Mark thread stack correctly in proc/<pid>/maps
Date: Fri, 3 Feb 2012 05:29:10 -0500
References: <20120116163106.GC7180@jl-vm1.vm.bytemark.co.uk> <CAAHN_R0O7a+RX7BDfas3+vC+mnQpp0h3y4bBa1u4T-Jt=S9J_w@mail.gmail.com> <CAHGf_=qA6EFue2-mNUg9udWV4xSx86XQsnyGV07hfZOUx6_egw@mail.gmail.com>
In-Reply-To: <CAHGf_=qA6EFue2-mNUg9udWV4xSx86XQsnyGV07hfZOUx6_egw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1483786.6JLQCoWP0J";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201202030529.14209.vapier@gentoo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>, Jamie Lokier <jamie@shareable.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org

--nextPart1483786.6JLQCoWP0J
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Friday 03 February 2012 03:01:35 KOSAKI Motohiro wrote:
> > Right now MAP_STACK does not mean anything since it is ignored. The
> > intention of this behaviour change is to make MAP_STACK mean that the
> > map is going to be used as a stack and hence, set it up like a stack
> > ought to be. I could not really think of a valid case for fixed size
> > stacks; it looks like a limitation in the pthread implementation in
> > glibc rather than a feature. So this patch will actually result in
> > uniform behaviour across threads when it comes to stacks.
> >=20
> > This does change vm accounting since thread stacks were earlier
> > accounted as anon memory.
>=20
> The fact is, now process stack and pthread stack clearly behave
> different dance. libc don't expect pthread stack grow automatically.
> So, your patch will break userland. Just only change display thing.

does it though ?  glibc doesn't keep track of the unused address space ...=
=20
that's what the kernel is for.  pthread_attr_setstacksize explicitly operat=
es=20
on the *minimum* stack size, not the *exact* size.

where exactly do you think userland would break ?

http://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_attr_sets=
tacksize.html
=2Dmike

--nextPart1483786.6JLQCoWP0J
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPK7b6AAoJEEFjO5/oN/WBTmEP/jxIHOJyzTBS9tMQigWzFfJJ
rGxabFz8/JE9HpyuyrW0BLTX2umsYkxSzVxcZendQO3Hgk3zt3TXLIVYXjx52q+2
nSmAQcbZRD0unjFy0giJdIApxU50UEaKsEhg2tzot+h6gBMRKuNVCuwGZruG5kV5
gLvfSMJrQDunrjsyrATFBGDQYsPR8nwXTUILBHRqGQrBiAyzEOmpfxEkTDEQKviX
ABb/+QDUoBInHBx8eBmHV8ziZs2gLp4XebUDNj5ybWjt93FS3mwqb1u217MdOdCP
cq8ip0Q5UAh++lq5W8Zs3e9g7HfkjDF3T/SaZu2zBNR+SXKawz4Xu8uwj4k7GLln
oTOFUqBCYk2lOSLAygLdSQWQGQI0x/EXvw+B+80Q7jlvKa2qU8dshaWGcnneSvwe
xbSPhn08qNdjnekmy9Yu66/O3uVqd+eZDV5LL1maBV4bJ6da2ijItzrUoKE4gbZk
1qxNutwDf68cA4W78fdmytcDCK8L7U7tyLCsMNFH4SwXDhjX3EG3BFdnNd0m6ynI
/A1EbmljMet9OzTpDOESpKLBYkRmDFPxx7utmMRWdAh8GDw88k52bc9g7AW8vf69
QNASE1hFgqf7x13FY9seJWokGj4oPGvfw9/fEk4igkvQXSFy5uxj9rqTNQtP/7Ce
6hF9hkyy8/CvD3kuZO3s
=BEta
-----END PGP SIGNATURE-----

--nextPart1483786.6JLQCoWP0J--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
