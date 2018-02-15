Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E75BD6B0022
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 22:53:25 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k38so1072553wre.23
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 19:53:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l38si918328wrl.367.2018.02.14.19.53.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Feb 2018 19:53:24 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Thu, 15 Feb 2018 14:53:15 +1100
Subject: Re: [LSF/MM ATTEND] memory allocation scope
In-Reply-To: <8b9d4170-bc71-3338-6b46-22130f828adb@suse.de>
References: <8b9d4170-bc71-3338-6b46-22130f828adb@suse.de>
Message-ID: <87po56q578.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>, lsf-pc@lists.linux-foundation.org, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 14 2018, Goldwyn Rodrigues wrote:

> Discussion with the memory folks towards scope based allocation
> I am working on converting some of the GFP_NOFS memory allocation calls
> to new scope API [1]. While other allocation types (noio, nofs,
> noreclaim) are covered. Are there plans for identifying scope of
> GFP_ATOMIC allocations? This should cover most (if not all) of the
> allocation scope.
>
> Transient Errors with direct I/O
> In a large enough direct I/O, bios are split. If any of these bios get
> an error, the whole I/O is marked as erroneous. What this means at the
> application level is that part of your direct I/O data may be written
> while part may not be. In the end, you can have an inconsistent write
> with some parts of it written and some not. Currently the applications
> need to overwrite the whole write() again.

So?
If that is a problem for the application, maybe it should use smaller
writes.  If smaller writes cause higher latency, then use aio to submit
them.

I doubt that splitting bios is the only thing that can cause a write
that reported as EIO to have partially completed.  An application should
*always* assume that EIO from a write means that the data on the device
is indistinguishable from garbage - shouldn't it?

NeilBrown


>
> Other things I am interested in:
>  - new mount API
>  - Online Filesystem Check
>  - FS cache shrinking
>
> [1] https://lwn.net/Articles/710545/
>
>
> --=20
> Goldwyn

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqFBCsACgkQOeye3VZi
gblVUw/8Cd/6TXzgPKjvvtVEVAFMRLkDHmKw146mKZGUDdiD+aRgQnWbVWPnm+xl
M8uaIt5GLrXKzxA55Jtq7WprvwxK7bCS23tXQWAYJjn857lKVsbTCNjT+9kj/Cwn
1Ig1bZTuvl+jWEzcZEJgjItguC1b5SFAlXSpfaF6/mf+0T3U3ljgeVyfsOw+I9iW
koTnP1H9IXksXq6X6dpS6qW4QsYgI2N54GBvLdS+tguUMnocjqDoLQnHh6fltMl+
9MJmTsAmnJg7RApQzJSSb99AyqMCcer+fg/Iz1lLwEBrHZmgbSbx6ufXvjCaWdzR
KqapmH4FG7OgfMNzQ+RFKc8kgG4zNWNcLsryzU+cQqTnFEYCW9FIcY89Ynd/vRo4
lU0PyUwwRHi57iSr2I+lYzm79avvlnvj0D0/VPNsPDTRsxPLfHYnbNK47g1VfhkI
LiNSOsLmdCLys+7N0KoaErTww/XDd8TMV3ImQ9JnyI3LZH2n29t/yd9mOs5Nurwc
vFT3nEBc3caqZ6hMNzR7aZdK3bQdL+9fe2BQ9rr/HEvA1uPWri4+i5m7N9KIP8nE
sVfLYL+Pa324jd00cI+GYLP57tA/GypxrYgM3lnQhpREjp12e63cavhS9QtTgwSf
ubylsB4zj7xKEjdJ41IGLwCX4/vEgQ7aGTmsZ8Uon+gGtxZpW14=
=eKnq
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
