Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
From: Arjan van de Ven <arjanv@redhat.com>
In-Reply-To: <E1844h3-0002Bt-00@w-gerrit2>
References: <E1844h3-0002Bt-00@w-gerrit2>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-GKyZ6V7vR9aKSA43Rb9d"
Date: 22 Oct 2002 21:56:25 +0200
Message-Id: <1035316645.4690.8.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gh@us.ibm.com>
Cc: Benjamin LaHaise <bcrl@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Martin J. Bligh" <mbligh@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-GKyZ6V7vR9aKSA43Rb9d
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2002-10-22 at 21:27, Gerrit Huizenga wrote:
 be fine with me - we are only planning on people using
> flags to shm*() or mmap(), not on the syscalls.  I thought Oracle
> was the one heavily dependent on the icky syscalls.

the icky syscalls are unusable for databases.. I'd be *really* surprised
if oracle could use them at all on x86....


--=-GKyZ6V7vR9aKSA43Rb9d
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQA9ta1pxULwo51rQBIRAjPyAJ4pxKSVXHr4VTh2jlxXSRvp7zzEfQCeNlcB
Pd76DiFz8SX1wRaQUubJZzE=
=Ul4s
-----END PGP SIGNATURE-----

--=-GKyZ6V7vR9aKSA43Rb9d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
