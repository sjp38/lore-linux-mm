Message-ID: <001901be9324$66ddcbf0$c80c17ac@clmsdev.local>
From: "Manfred Spraul" <masp0008@stud.uni-sb.de>
Subject: Re: Hello
Date: Fri, 30 Apr 1999 18:12:21 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>, "James E. King, III" <jking@ariessys.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin C.R. LaHaise <blah@kvack.org> wrote:
>I think someone created patches that make a ramdisk out of the really high
>memory.  Try doing a search of the linux-kernel archives -- I remember
>seeing it withing the past 3 or 4 months.  Hope this helps!
I wrote that patch, but I abandoned it because I think that the performance
would be inacceptable: the data is first cached in the buffer cache,
and later moved into high memory, and if you access the data it's
moved back. I think that the memmove() calls would slow down
the system considerably.

If you need the patch I can send it to you.

But I have a new idea: what about replacing the current 'shm' implementation
with a high memory aware implementation.
* use high memory if high memory is available. We only need a simple
   bitmap for the high-mem. max_mapnr remains 1 or 2 GB, page_map
   is not extended.
* if you have more than 2 Gb memory, then you don't want that the system
    starts to swap out. So there is no need to support swap for that memory.
    This means: no double buffering etc required.
* I haven't yet read the new Xeon page table extentions,
  but perhaps we could support up to 64 GB memory without changing the
  rest of the OS   (Intel could write such a driver for Windows NT,
  I'm sure this is possible for Linux, too).
* it's very easy for the user mode programmers, no new interfaces.

I think that this implementation would required only a few hundred lines.

What do you think about this?

Regards,
    Manfred


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
