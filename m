Message-ID: <4005F128.3080208@yahoo.es>
Date: Wed, 14 Jan 2004 20:47:20 -0500
From: Roberto Sanchez <rcsanchez97@yahoo.es>
MIME-Version: 1.0
Subject: Re: 2.6.1-mm3
References: <20040114014846.78e1a31b.akpm@osdl.org>
In-Reply-To: <20040114014846.78e1a31b.akpm@osdl.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig23B9F10AC9EE145ADAB3AB39"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig23B9F10AC9EE145ADAB3AB39
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm3/
> 
> 
> - A big ppc64 update from Anton
> 
> - Added Nick's CPU scheduler patches for hyperthreaded/SMT CPUs.  This work
>   needs lots of testing and review from those who care about and work upon
>   this feature, please.
> 
> - An I/O scheduler tuning patch.  This is the 114th patch against the
>   anticipatory scheduler and we're nearly finished, honest.  Now would be a
>   good time for people to run the appropriate benchmarks.
> 
>   We're still not as good as deadline on some seeky loads, and deep SCSI
>   TCQ still hurts a lot.  But it is looking good on average.
> 
> - Plenty of other random stuff

I am still getting lock-ups on my system (nForce2 w/ Athlon XP 2500+).
I am currently stuck at 2.6.1-rc1-mm1.  If there is anything I can do
to help track down the problem I would be happy to help, I just need
some  pointers on where to start.

-Roberto Sanchez

--------------enig23B9F10AC9EE145ADAB3AB39
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFABfEyTfhoonTOp2oRAjTuAKDdE100uhKV8y8kJ1jyZycvJJ8FpACgr0PA
KCghWM/n97DA5cEpJWXhZfU=
=xSiP
-----END PGP SIGNATURE-----

--------------enig23B9F10AC9EE145ADAB3AB39--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
