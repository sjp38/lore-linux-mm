Date: Fri, 10 Dec 1999 13:21:21 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <Pine.LNX.4.10.9912100015520.10946-100000@chiara.csoma.elte.hu>
Message-ID: <Pine.LNX.4.05.9912101308140.31379-100000@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 1999, Ingo Molnar wrote:
> On Thu, 9 Dec 1999, Rik van Riel wrote:
> 
> > a "real" zoned allocator. Not a 2.4 thing,
> 
> would you mind elaborating what such a "real" zoned allocator has,
> compared to the current one?

It would assign certain types of use to certain
zones of memory and do so dynamically.

Ie. we'd have a 4MB zone allocated to kernel and
pagetable stuff and other areas assigned to
user pages. Now when we need to have another kernel
data area we can move pages out of one of the user
area's as needed. We can also move out arbitrarily
large chunks of contiguous user pages if we need
to allocate such an area.

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
