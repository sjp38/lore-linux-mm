Date: Fri, 31 Jul 1998 09:14:21 +1000
Message-Id: <199807302314.JAA09103@vindaloo.atnf.CSIRO.AU>
From: Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>
Subject: Re: writable swap cache explained (it's weird)
In-Reply-To: <Pine.LNX.3.96.980730142318.6696A-100000@penguin.transmeta.com>
References: <Pine.LNX.3.95.980730150740.17264B-100000@as200.spellcast.com>
	<Pine.LNX.3.96.980730142318.6696A-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Bill Hawes <whawes@transmeta.com>, Linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds writes:
> 
> 
> On Thu, 30 Jul 1998, Benjamin C.R. LaHaise wrote:
> > 
> > (a) sounds like the Obvious Thing To Do in the mmap method for /proc, but
> > will break xdos.  Wtf were they thinking in writing that insane code?
> > Hmmm, this bug probably applies to 2.0 too....  in a much more subtle
> > fashion.
> 
> The insane code is indeed insane, but I think I understand why they did
> it: they didn't want to mess around with sysv shared memory regions.
> 
> I'd love to just completely get rid of mmap() on /proc/self/mem, because
> it actually is a bad idea completely (not just the shared mappings - even
> a private mapping of another mapping that is shared has simply completely
> untenable logical problems). 
> 
> I'd much more prefer for somebody to take the time to change dosemu to use
> the standard (and supported) sysv shared memory setup than to make any
> kernel changes.. 

I think it would be better if they used the new POSIX.4 SHM support
(shm_open(3) and friends). To do that, though, the shmfs patch would
need to be included in the kernel, though. Yeah, yeah, I know: feature
freeze. But when has that ever stopped you? ;-)

				Regards,

					Richard....
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
