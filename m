Message-Id: <200310220246.h9M2ko08007330@turing-police.cc.vt.edu>
Subject: Re: 2.6.0-test8-mm1 
In-Reply-To: Your message of "Tue, 21 Oct 2003 19:27:25 EDT."
             <1066778844.768.348.camel@localhost>
From: Valdis.Kletnieks@vt.edu
References: <Pine.LNX.4.44.0310212141290.32738-100000@phoenix.infradead.org> <200310220053.13547.schlicht@uni-mannheim.de>
            <1066778844.768.348.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1296134294P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Oct 2003 22:46:50 -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Thomas Schlichter <schlicht@uni-mannheim.de>, James Simmons <jsimmons@infradead.org>, Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1296134294P
Content-Type: text/plain; charset=us-ascii

On Tue, 21 Oct 2003 19:27:25 EDT, Robert Love said:
> On Tue, 2003-10-21 at 18:53, Thomas Schlichter wrote:
> 
> > For me the big question stays why enabling the DEBUG_* options results in a
 
> > corrupt cursor and the false dots on the top of each row... (with both 
> > kernels)
> 
> Almost certainly due to CONFIG_DEBUG_SLAB or CONFIG_DEBUG_PAGEALLOC,
> which debug memory allocations and frees.
> 
> Code that commits the usual memory bugs (use-after-free, etc.) will
> quickly die with these set, whereas without them the bug might never
> manifest.

Right.  DEBUG_SLAB and DEBUG_PAGEALLOC will change where things end up in
memory.  The part that *I* was surprised at was that turning them on did *NOT*
make the code quickly die as expected - but it *did* corrupt the on-screen
image.  That's telling me that the DEBUG stuff is setting canaries that end up
in memory locations that the fbdev code thinks are destined for the display
pixels.  (And conversely, that when you build without those two debug options,
that the fbdev code is parking those now not visibly corrupted pixels on top of
somebody's pointer chains and that's where the memory corruption is coming
from.

Or I could just be full of it as usual.. :)

--==_Exmh_1296134294P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQE/le+acC3lWbTT17ARAtcVAKD3y/GoHp6q7tQKe814QFnDCZl3igCg5xPR
8P8D3oLqb4ujlZ/UviIzLOw=
=wWFB
-----END PGP SIGNATURE-----

--==_Exmh_1296134294P--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
