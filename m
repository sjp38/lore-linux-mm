Subject: Re: ptes flags in compressed cache
References: <20001026135245.B19100@linux.ime.usp.br>
	<20001026165821.W20050@redhat.com>
From: Christoph Rohland <cr@sap.com>
Date: 27 Oct 2000 09:59:13 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Thu, 26 Oct 2000 16:58:21 +0100"
Message-ID: <m3bsw6vhny.fsf@linux.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Rodrigo S. de Castro" <rcastro@linux.ime.usp.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> On Thu, Oct 26, 2000 at 01:52:45PM -0200, Rodrigo S. de Castro wrote:
> > 
> > 	I am working on a compressed cache for 2.2.16 and I am
> > currently in a cache with no compression implementation. Well, at this
> > step, I gotta a doubt of how can I mark the pages (actually, ptes)
> > that are in my cache and neither present in memory nor in swap. This
> > is essential when I have a page fault, and this page is not present in
> > memory.
> 
> Reserve a SWP_ENTRY for compressed pages.  There's precedent for that:
> SHM in 2.2 already uses that mechanism for swapped-out shared memory
> pages.

No, shm does not use a SWP_TYPE. It only pretends to do ;-)

Greetings
                Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
