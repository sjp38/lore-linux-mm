Message-ID: <4000125A.3020108@yahoo.es>
Date: Sat, 10 Jan 2004 09:55:22 -0500
From: Roberto Sanchez <rcsanchez97@yahoo.es>
MIME-Version: 1.0
Subject: Re: 2.6.1-mm2
References: <20040110014542.2acdb968.akpm@osdl.org>
In-Reply-To: <20040110014542.2acdb968.akpm@osdl.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDE0B507CD424250292161865"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDE0B507CD424250292161865
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm2/
> 

I am still seeng the constant lockups that started with -rc2-mm1.
For the moment I have reverted to -rc1-mm1.  My setup:

Athlon XP 2500+
1 GB memory
nForce2 mobo at 333MHz FSB

If there is anything I can do to help track this down, please
let me know.  But, I am not yet much of a kernel hacker, so I
will need instruction.

-Roberto Sanchez

--------------enigDE0B507CD424250292161865
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFAABJkTfhoonTOp2oRAsHAAKDQh++LpXGNlTL9XbZTrbuIXgWb8QCfV7dc
F4yiGwRTP5NSoMiFxgXzduA=
=MVFz
-----END PGP SIGNATURE-----

--------------enigDE0B507CD424250292161865--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
