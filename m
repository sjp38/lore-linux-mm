Subject: Re: 2.5.69-mm7
References: <20030519012336.44d0083a.akpm@digeo.com>
From: Alexander Hoogerhuis <alexh@ihatent.com>
Date: 19 May 2003 12:58:38 +0200
In-Reply-To: <20030519012336.44d0083a.akpm@digeo.com>
Message-ID: <874r3r2of5.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton <akpm@digeo.com> writes:
>
> [SNIP]
>

Caught this one during make modules_install:

WARNING: /lib/modules/2.5.69-mm7/kernel/fs/ext2/ext2.ko needs unknown symbol __bread_wq

mvh,
A
- -- 
Alexander Hoogerhuis                               | alexh@ihatent.com
CCNP - CCDP - MCNE - CCSE                          | +47 908 21 485
"You have zero privacy anyway. Get over it."  --Scott McNealy
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Processed by Mailcrypt 3.5.8 <http://mailcrypt.sourceforge.net/>

iD8DBQE+yLjbCQ1pa+gRoggRAg2UAKCSjvT4uHD6lENM0O5lqoZSZZ0QigCgq0rm
IA+CUUNeFXrjOPfbq9V7/f8=
=bcye
-----END PGP SIGNATURE-----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
