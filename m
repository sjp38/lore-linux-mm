Received: from MIT.EDU (SOUTH-STATION-ANNEX.MIT.EDU [18.72.1.2])
	by kvack.org (8.8.7/8.8.7) with SMTP id KAA12370
	for <linux-mm@kvack.org>; Tue, 23 Mar 1999 10:49:34 -0500
Message-Id: <199903231549.KAA20478@x15-cruise-basselope>
Subject: Re: LINUX-MM 
In-Reply-To: Your message of "Tue, 23 Mar 1999 15:16:54 +0100."
             <Pine.LNX.4.03.9903231514290.10060-100000@mirkwood.dummy.home>
Date: Tue, 23 Mar 1999 10:49:11 EST
From: Kev <klmitch@MIT.EDU>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@nl.linux.org>
Cc: Matthias Arnold <Matthias.Arnold@edda.imsid.uni-jena.de>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Thanks for your reply.Unfortunately the memory is not (at least
> > not completely) returned to the system after the program has
> > finished (as the OS comand 'free' tells me).
> 
> Hmm, what version of the kernel are you using?
> 
> IIRC there's a slight bug in some of the newer kernels
> where the swap cache isn't being freed when you exit
> your program, but only later on when the system tries
> to reclaim memory...

I believe the problem lies in the fact that there is not enough
SysV shared memory available.
-- 
Kevin L. Mitchell <klmitch@mit.edu>
-------------------------  -. .---- --.. ..- -..-  --------------------------
http://web.mit.edu/klmitch/www/               (PGP keys availiable from here)
    RSA AE87D37D/1024:  DE EA 1E 99 3F 2B F9 23  A0 D8 05 E0 6F BA B9 D2
    DSS ED0DB34E/1024: D9BF 0E74 FDCB 43F5 C597  878F 9455 EC24 ED0D B34E
    DH  2A2C31D4/2048: 1A77 4BA5 9E32 14AE 87DA  9FEC 7106 FC62 2A2C 31D4

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
