Date: Sun, 29 Apr 2001 03:56:26 -0400
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: RFC: Bouncebuffer fixes
Message-ID: <20010429035626.B14210@devserv.devel.redhat.com>
References: <20010428170648.A10582@devserv.devel.redhat.com> <20010429020757.C816@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010429020757.C816@athlon.random>; from andrea@suse.de on Sun, Apr 29, 2001 at 02:07:57AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, alan@lxorguk.ukuu.org.uk, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 29, 2001 at 02:07:57AM +0200, Andrea Arcangeli wrote:
> Hmm I cannot remeber any flush_dirty_buffers called by alloc_bounce_page in
> any patch floating around, certainly there isn't any in my tree, so the
> above recursion certainly cannot happen here.

It's in 2.4.3-acFoo



> 	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.4/2.4.4aa1/00_highmem-deadlock-3

This looks like the code in Alan's tree around 2.4.3-ac7, and that is NOT 
enough to fix the deadlock. With that patch, tests deadlock within 10 minutes....

One of the reasons it deadlocks is because GFP_BUFFER can sleep here,
without the guarantee of progress. The regular VM threads that should
guarantee progress end up sleeping here. 

Greetings,
   Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
