Date: Thu, 29 Apr 1999 12:20:22 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Hello
In-Reply-To: <001901be9324$66ddcbf0$c80c17ac@clmsdev.local>
Message-ID: <Pine.LNX.3.95.990429121441.24902A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <masp0008@stud.uni-sb.de>
Cc: "James E. King, III" <jking@ariessys.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 30 Apr 1999, Manfred Spraul wrote:

> If you need the patch I can send it to you.

=)  The most memory any of my machines have is 64 megs.  It would be nice
if more developers had systems with 4 gigs of memory...

> But I have a new idea: what about replacing the current 'shm' implementation
> with a high memory aware implementation.

> * it's very easy for the user mode programmers, no new interfaces.
> 
> I think that this implementation would required only a few hundred lines.
> 
> What do you think about this?

The implementation I saw Stephen post about is actually even better: add a
bit to page->flags to indicate that the memory is HIGH memory, which only
gets returned by get_free_page() if the caller inclues a GFP_HIGH_OKAY
flag.  Then, these pages can be used to fill in anonymous user mappings
and shared memory.  Presto chango, maybe a couple of hundred line patch
and you've got support for 4GB on intel, albeit with restrictions.  Then
the Xeon 36 bit page tables are a simple extension from there.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
