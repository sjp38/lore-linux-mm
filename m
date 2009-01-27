Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C8D426B0044
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 16:45:46 -0500 (EST)
Message-ID: <497F8027.2060809@suse.com>
Date: Tue, 27 Jan 2009 16:44:07 -0500
From: Jeff Mahoney <jeffm@suse.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kmalloc: Return NULL instead of link failure
References: <4975F376.4010506@suse.com> <20090127133723.46eb7035.akpm@linux-foundation.org>
In-Reply-To: <20090127133723.46eb7035.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
> Strange patch format, but it applied.

Ugh, sorry about that. I forgot to disable the GPG signing. It escapes
- -'s like that.

> I'll punt this patch in the Pekka direction.
> 
> Do you think we should include it in 2.6.28.x?

I think so. It's a corner case, but does fix a build failure.

- -Jeff

- --
Jeff Mahoney
SUSE Labs
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAkl/gCcACgkQLPWxlyuTD7IdcwCgkdOmH3P8a9q1RQYsOcCkG8C0
TYsAn3rEJMROguhVqbWuFlzg58t+vVEL
=RM/e
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
