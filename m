Date: Thu, 30 Jul 1998 14:25:57 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: writable swap cache explained (it's weird)
In-Reply-To: <Pine.LNX.3.95.980730150740.17264B-100000@as200.spellcast.com>
Message-ID: <Pine.LNX.3.96.980730142318.6696A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Bill Hawes <whawes@transmeta.com>, Linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Thu, 30 Jul 1998, Benjamin C.R. LaHaise wrote:
> 
> (a) sounds like the Obvious Thing To Do in the mmap method for /proc, but
> will break xdos.  Wtf were they thinking in writing that insane code?
> Hmmm, this bug probably applies to 2.0 too....  in a much more subtle
> fashion.

The insane code is indeed insane, but I think I understand why they did
it: they didn't want to mess around with sysv shared memory regions.

I'd love to just completely get rid of mmap() on /proc/self/mem, because
it actually is a bad idea completely (not just the shared mappings - even
a private mapping of another mapping that is shared has simply completely
untenable logical problems). 

I'd much more prefer for somebody to take the time to change dosemu to use
the standard (and supported) sysv shared memory setup than to make any
kernel changes.. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
