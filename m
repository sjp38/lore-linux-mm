Message-ID: <35C0CE3D.88618DE3@transmeta.com>
Date: Thu, 30 Jul 1998 12:49:17 -0700
From: Bill Hawes <whawes@transmeta.com>
MIME-Version: 1.0
Subject: Re: writable swap cache explained (it's weird)
References: <Pine.LNX.3.95.980730150740.17264B-100000@as200.spellcast.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Linux-kernel <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin C.R. LaHaise wrote:

> There are two options:
>
>         a) disallow MAP_SHARED mappings of anonymous memory from
> /proc/self/mem
>
>         b) implement shared anon mappings
>
> (a) sounds like the Obvious Thing To Do in the mmap method for /proc, but
> will break xdos.  Wtf were they thinking in writing that insane code?
> Hmmm, this bug probably applies to 2.0 too....  in a much more subtle
> fashion.
>
> As for (b), I'll try to present code by Saturday, as it is a nice feature
> to add to our cap. =)  (No, it's not going to be anything like the awful
> shm code.)

For implementing shared anon mapping, why can't you just mmap a temp file
and then unlink it? This should provide the expected capabilities, and the
disk image would disappear when the last mapping closes.

Seems like that should work for the xdos case, though it would require a few
changes to the code.

Regards,
Bill


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
