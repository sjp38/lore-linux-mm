From: Florian Schanda <ma1flfs@bath.ac.uk>
Reply-To: ma1flfs@bath.ac.uk
Subject: Re: 2.6.0-test5-mm4
Date: Mon, 22 Sep 2003 15:30:04 +0100
References: <20030922013548.6e5a5dcf.akpm@osdl.org> <200309221317.42273.alistair@devzero.co.uk>
In-Reply-To: <200309221317.42273.alistair@devzero.co.uk>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Description: clearsigned data
Content-Disposition: inline
Message-Id: <200309221530.17062.ma1flfs@bath.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alistair J Strachan <alistair@devzero.co.uk>, Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Monday 22 September 2003 13:17, Alistair J Strachan wrote:
> -mm4 won't mount my ext3 root device whereas -mm3 will. Presumably this is
> some byproduct of the dev_t patches.

I don't think this has to do with ext3, since my root xfs partition can't be 
mounted either.

> VFS: Cannot open root device "302" or hda2.
> Please append correct "root=" boot option.
> Kernel Panic: VFS: Unable to mount root fs on hda2.

same over here, except replace hda2 with sda3 and (302 with 803 of couse).

> One possible explanation is that I have devfs compiled into my kernel. I do
> not, however, have it automatically mounting on boot. It overlays /dev
> (which is populated with original style device nodes) after INIT has
> loaded.

I disabled mount at root and created some device nodes, but it still doesn't 
work, befor that I had pure devfs. Reading the config help for devfs says 
it's obsoleted, and stripped down to a "bare minimum to not break anyting". 
Does that "bare minimum" include hard disks?

	Florian
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/bwdvfCf8muQVS4cRAmQ0AJ9N6WBJIOKholW9Rf2QV6wdxlWyHACeNsoP
niBAErfeLd0NR0WR6ElKOhU=
=Iysp
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
