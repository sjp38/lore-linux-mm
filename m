Date: Fri, 30 Oct 1998 14:18:33 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: mmap() for a cluster of pages
In-Reply-To: <m0zZJjV-0007V2C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.95.981030140129.1612B-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, pokam@cs.tu-berlin.de, Linux-MM@kvack.org, number6@the-village.bc.nu
List-ID: <linux-mm.kvack.org>

On Fri, 30 Oct 1998, Alan Cox wrote:

> > > My guess is simply that noone's encountered this bug before, but it's
> > > there.  
> > 
> > We should be OK.  Alan will no doubt scream if I'm wrong here.
> 
> It seems to be ok. All the bug reports in sound currently are quite
> different things

I was mistaken; all's well.  The 2.0 code wraps this in a mem_map_reserve
which my eyes blindly skipped.  Other code performing the same trick looks
right too (the bttv driver; the fb stuff looks like it has its buffers
outside of normal RAM). 

		-ben

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
