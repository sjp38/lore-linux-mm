From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004111820.LAA66150@google.engr.sgi.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
Date: Tue, 11 Apr 2000 11:20:45 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0004111438440.1118-100000@duckman.conectiva> from "Rik van Riel" at Apr 11, 2000 02:40:37 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Andrea Arcangeli <andrea@suse.de>, Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Tue, 11 Apr 2000, Andrea Arcangeli wrote:
> > On Mon, 10 Apr 2000, Kanoj Sarcar wrote:
> > 
> > >While forking, a parent might copy a swap handle into the child, but we
> > 
> > That's a bug in fork. Simply let fork to check if the swaphandle
> > is SWAPOK or not before increasing the swap count. If it's
> > SWAPOK then swap_duplicate succesfully,
> 
> "it was hard to write, it should be hard to maintain"
> 
> Relying on pieces of magic like this, spread out all over
> the kernel source will make the code more fragile and hell
> to maintain.

No, its not magic, since it still doesn't work. Watch out for mail 
from me as to why ... 

> 
> Unless somebody writes the documentation for all of this,
> of course...
>

Precisely, that's why I started off Documentation/vm/locking.
It would be _really_ nice if folks doing locking (or for that matter,
any other delicate) work were to update these files ...

KAnoj
 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/		http://www.surriel.com/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
