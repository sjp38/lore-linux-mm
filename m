Message-Id: <200401211920.i0LJKZ2a003504@turing-police.cc.vt.edu>
Subject: Re: 2.6.1-mm4 
In-Reply-To: Your message of "Wed, 21 Jan 2004 19:46:32 +0100."
             <400EC908.4020801@gmx.de>
From: Valdis.Kletnieks@vt.edu
References: <20040115225948.6b994a48.akpm@osdl.org> <4007B03C.4090106@gmx.de>
            <400EC908.4020801@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_668682134P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 21 Jan 2004 14:20:35 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Prakash K. Cheemplavam" <PrakashKC@gmx.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_668682134P
Content-Type: text/plain; charset=us-ascii

On Wed, 21 Jan 2004 19:46:32 +0100, "Prakash K. Cheemplavam" said:
> Ok, here is the stack backtrace:
> 
> I hope it helps, otherwise I could try compiling in frame-pointers. (I 
> used another logger to get this...)
> 
> Is it nvidia driver doing something bad (which earlier kernels didn't do)?
> 
> Jan 21 19:25:39 tachyon Badness in pci_find_subsys at 
> drivers/pci/search.c:132
> Jan 21 19:25:39 tachyon Call Trace:
> Jan 21 19:25:39 tachyon [<c027a7f8>] pci_find_subsys+0xe8/0xf0
> Jan 21 19:25:39 tachyon [<c027a82f>] pci_find_device+0x2f/0x40
> Jan 21 19:25:39 tachyon [<c027a6e8>] pci_find_slot+0x28/0x50

If this is the NVidia graphics driver, it's been doing it at least since 2.5.6something,
at least that I've seen.  It's basically calling pci_find_slot in an interrupt context,
which ends up calling pci_find_subsys which complains about it.  One possible
solution would be for the code to be changed to call pci_find_slot during module
initialization and save the return value, and use that instead.  Yes, I know this
prevents hotplugging.  Who hotplugs graphics cards? ;)

--==_Exmh_668682134P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFADtEDcC3lWbTT17ARAkolAKC0Bsttm2gn8U8maWRfuHx2Ji+uCwCeI/Pw
4uUuV6n8lRoncT+qbO7W0Bw=
=j/My
-----END PGP SIGNATURE-----

--==_Exmh_668682134P--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
