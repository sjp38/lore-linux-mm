Subject: Re: [PATCH] Fix races in 2.4.2-ac22 SysV shared memory
Date: Fri, 23 Mar 2001 22:29:45 +0000 (GMT)
In-Reply-To: <Pine.GSO.4.21.0103231721120.10092-100000@weyl.math.psu.edu> from "Alexander Viro" at Mar 23, 2001 05:23:29 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14ga44-0005Zq-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, Christoph Rohland <cr@sap.com>
List-ID: <linux-mm.kvack.org>

> > > 	+       page = find_lock_page(mapping, idx);
> > > 
> > > Ehh.. Sleeping with the spin-lock held? Sounds like a truly bad idea.
> > 
> > Umm find_lock_page doesnt sleep does it ?
> 
> It certainly does. find_lock_page() -> __find_lock_page() -> lock_page() ->
> -> __lock_page() -> schedule().

Ok I missed the lock page one. Yep.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
