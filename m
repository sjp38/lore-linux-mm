Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6ED36B0292
	for <linux-mm@kvack.org>; Tue, 23 May 2017 13:14:26 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v195so65214566qka.1
        for <linux-mm@kvack.org>; Tue, 23 May 2017 10:14:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h42si22416082qtc.247.2017.05.23.10.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 10:14:25 -0700 (PDT)
Message-ID: <1495559662.20270.42.camel@redhat.com>
Subject: Re: [PATCH] mm: make kswapd try harder to keep active pages in cache
From: Rik van Riel <riel@redhat.com>
Date: Tue, 23 May 2017 13:14:22 -0400
In-Reply-To: <1495549403-3719-1-git-send-email-jbacik@fb.com>
References: <1495549403-3719-1-git-send-email-jbacik@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-q7pfu640lUfmgSlp6Zwj"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>, akpm@linux-foundation.org, kernel-team@fb.com, hannes@cmpxchg.org, linux-mm@kvack.org


--=-q7pfu640lUfmgSlp6Zwj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-05-23 at 10:23 -0400, Josef Bacik wrote:

> My approach here is twofold.=C2=A0=C2=A0First, keep track of the differen=
ce in
> inactive and slab pages since the last time kswapd ran.=C2=A0=C2=A0In the=
 first
> run this will just be the overall counts of inactive and slab, but
> for
> each subsequent run we'll have a good idea of where the memory
> pressure
> is coming from.=C2=A0=C2=A0Then we use this information to put pressure o=
n
> either
> the inactive lists or the slab caches, depending on where the
> pressure
> is coming from.

> Signed-off-by: Josef Bacik <jbacik@fb.com>

This looks totally reasonable to me.

Acked-by: Rik van Riel <riel@redhat.com>
--=-q7pfu640lUfmgSlp6Zwj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZJG3uAAoJEM553pKExN6D5ugH/3tTOFovoDzq3vizllxGX4GQ
jCFtfHnX0tYi9xbU2pCtQsMzXUjKn+umUftvx7VEw1DLBJr55kOFZK6Pu4s5CFm5
FptBnACz6A8jKIAzZcl1Bc6mrc5NLRmhDgVQjjCsz0SFsClEapMDKRhyrQA2mWlB
lcoXgQ5cwWYEm2eC5JK1RA14umx/go6w0r8BrVheex0ENnnSqlJMokFoyCaeUHYG
MyWaSjFjsqa6v2dS4duQMfSdPBmO8vCXCGypR1PTG+DtErr0fxZd9zTJRyv4+3Ou
g8HKlJJm71GpgGzmBa7oj9/fz1SNVLVSilpmR9YwRLuDEd8mMlaT2UMpmt699g8=
=fjkC
-----END PGP SIGNATURE-----

--=-q7pfu640lUfmgSlp6Zwj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
