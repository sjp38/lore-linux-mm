Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 858156006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 10:44:13 -0400 (EDT)
Received: by wyj26 with SMTP id 26so699055wyj.14
        for <linux-mm@kvack.org>; Thu, 08 Jul 2010 07:44:12 -0700 (PDT)
Date: Thu, 8 Jul 2010 15:44:07 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH] Add trace event for munmap
Message-ID: <20100708144407.GA8141@us.ibm.com>
References: <1278597931-26855-1-git-send-email-emunson@mgebm.net>
 <1278598955.1900.152.camel@laptop>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Content-Disposition: inline
In-Reply-To: <1278598955.1900.152.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Eric B Munson <emunson@mgebm.net>, akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, anton@samba.org
List-ID: <linux-mm.kvack.org>


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 08 Jul 2010, Peter Zijlstra wrote:

> On Thu, 2010-07-08 at 15:05 +0100, Eric B Munson wrote:
> > This patch adds a trace event for munmap which will record the starting
> > address of the unmapped area and the length of the umapped area.  This
> > event will be used for modeling memory usage.
>=20
> Does it make sense to couple this with a mmap()/mremap()/brk()
> tracepoint?
>=20

We were using the mmap information collected by perf, but I think
those might also be useful so I will send a followup patch to add
them.

--=20
Eric B Munson
IBM Linux Technology Center
emunson@mgebm.net


--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkw15DcACgkQsnv9E83jkzqeGwCgoFBc6kS51O01xydGT2QyVSUt
DdQAoPPcppaW7XQAUPoE9pPjmFzKah0H
=xsXW
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
