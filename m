Date: Sat, 1 Aug 1998 23:54:03 -0500 (CDT)
From: Eric W Biederman <eric@flinx.npwt.net>
Reply-To: ebiederm+eric@npwt.net
Subject: Re: writable swap cache explained (it's weird)
In-Reply-To: <Pine.LNX.3.96.980730142318.6696A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.02.9808012342400.424-100000@iddi.npwt.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Bill Hawes <whawes@transmeta.com>, Linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Thu, 30 Jul 1998, Linus Torvalds wrote:

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

Good guess but no.  Dosemu already uses sysv shared memory regions
where it can.  But for some applications it needs page level control, 
and sysv doesn't give you that.

Further the dosemu history states that when it was attempted to map a
temporary file, and use the standard mmap functionality that way, the
performance became unacceptable on nfs filesystems.

So /proc/self/mem was the only solution open to dosemu, that provided
the required level of performance and control.
 
> I'd love to just completely get rid of mmap() on /proc/self/mem, because
> it actually is a bad idea completely (not just the shared mappings - even
> a private mapping of another mapping that is shared has simply completely
> untenable logical problems). 

I agree and this is why I have put a considerable amount of effort into
implementing a posix shared memory interface. 

Eric 




--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
