Date: Sun, 29 Apr 2001 09:41:21 -0400
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: RFC: Bouncebuffer fixes
Message-ID: <20010429094121.B3131@devserv.devel.redhat.com>
References: <20010428170648.A10582@devserv.devel.redhat.com> <20010429020757.C816@athlon.random> <20010429035626.B14210@devserv.devel.redhat.com> <20010429151711.A11395@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010429151711.A11395@athlon.random>; from andrea@suse.de on Sun, Apr 29, 2001 at 03:17:11PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org, alan@lxorguk.ukuu.org.uk, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 29, 2001 at 03:17:11PM +0200, Andrea Arcangeli wrote:

> GFP_BUFFER doesn't provide guarantee of progress and that's fine, as far
> as GFP_BUFFER allocations returns NULL eventually there should be no
> problem. The fact some emergency buffer is in flight is just the guarantee
> of progress because after unplugging tq_disk we know those emergency
> buffers will be released without the need of further memory allocations.

This is NOT what is happening. Look at the code. It does a GFP_BUFFER
allocation before even attempting to use the bounce-buffers! So there is no
guarantee of having emergency bouncebuffers in flight.

Also, I'm not totally convinced that GFP_BUFFER will never sleep before
running the tq_disk, but I agree that that can qualify as a seprate bug.


Greetings,
   Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
