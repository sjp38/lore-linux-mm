Date: Tue, 25 Aug 1998 21:34:35 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: State of things?
In-Reply-To: <Pine.LNX.3.95.980824233056.8914A-100000@as200.spellcast.com>
Message-ID: <Pine.LNX.3.96.980825212725.475e-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Aug 1998, Benjamin C.R. LaHaise wrote:

> Okay, I'm back in Toronto from sunny California, and I'm wondering if
> someone would be so kind as to enlighten me about the current state of mm
> in 2.1/plans for 2.3...

Well:
- the fragmentation problems have been hidden fairly well by
  making the dcache better prunable and by allocating less
  inodes on small systems
- some swap count 'overflow' has been fixed by Stephen
  (there was a leak on 127+ users of one page) -- has this been
  merged?
- Stephen implemented swap partitions of up to 2 GB -- not yet merged
- Bill Hawes did an awful lot of debugging, he fixed several
  (all?) cases of "found a writable swap cache page"
- I updated some documentation and am busy writing more (for 2.2,
  documentation has my priority)
- I am working on proper Out-of-VM process killing code (which
  might even work by now :-)
- DaveM is working on a fast hashing scheme for VMAs (read the
  "2.1 makes Electric Fence 22x slower" thread on linux-kernel)
- Eric has been busy coding SHMfs and doing dirty pages in the
  page cache -- scheduled for 2.3 integrations
- Linus has announced a definite code freeze (at 2.1.115)

Look at http://roadrunner.swansea.uk.linux.org/jobs.shtml
or http://www.phys.uu.nl/~riel/mm-patch/todo.html for more
info on what to do...

btw, did you have a nice holiday?

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
