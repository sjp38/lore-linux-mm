Date: Thu, 30 Jul 1998 15:20:20 -0400 (`eoyyyyp)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: writable swap cache explained (it's weird)
In-Reply-To: <35BF43AC.F0F0C14F@transmeta.com>
Message-ID: <Pine.LNX.3.95.980730150740.17264B-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bill Hawes <whawes@transmeta.com>
Cc: Linux-kernel <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Jul 1998, Bill Hawes wrote:

> To fix this I think we need to mark the whole mess as unswappable. It
> won't work to just test for a writable pte to a shared page -- in this
> case one of the sharings is only readable. So if the readable one gets
> swapped out first, the remaining mappings would still be a problem.
> 
> Anyone have any ideas for the best way to detect and handle this case?

There are two options:

	a) disallow MAP_SHARED mappings of anonymous memory from
/proc/self/mem

	b) implement shared anon mappings

(a) sounds like the Obvious Thing To Do in the mmap method for /proc, but
will break xdos.  Wtf were they thinking in writing that insane code?
Hmmm, this bug probably applies to 2.0 too....  in a much more subtle
fashion.

As for (b), I'll try to present code by Saturday, as it is a nice feature
to add to our cap. =)  (No, it's not going to be anything like the awful
shm code.) 

		-ben

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
