From: Rudmer van Dijk <rudmer@legolas.dynup.net>
Subject: Re: 2.5.69-mm8
Date: Thu, 22 May 2003 23:21:15 +0200
References: <20030522021652.6601ed2b.akpm@digeo.com> <3ECCBD6B.9070807@aitel.hist.no>
In-Reply-To: <3ECCBD6B.9070807@aitel.hist.no>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Description: clearsigned data
Content-Disposition: inline
Message-Id: <200305222321.26880.rudmer@legolas.dynup.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Thursday 22 May 2003 14:07, Helge Hafting wrote:
> Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.
> >69-mm8/
> >
> > . One anticipatory scheduler patch, but it's a big one.  I have not
> > stress tested it a lot.  If it explodes please report it and then boot
> > with elevator=deadline.
> >
> > . The slab magazine layer code is in its hopefully-final state.
> >
> > . Some VFS locking scalability work - stress testing of this would be
> >   useful.
>
> It seems to work fine for UP and survives a kernel compile.

also for me, UP no preempt and it is running for 11 hours now without 
problems. It survived a kernel compile, compilation of the kde-network 
package and every other normal desktop-system usage. 

	Rudmer
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE+zT9ShvANkaSdp/IRAh/IAJ4wuUoONk96noYpbLJOBbhvDsmNwwCeKsNa
S9VGQ6HCiwrlQJv2rEjOBMA=
=386g
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
