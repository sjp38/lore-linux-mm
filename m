Date: Sun, 29 Oct 2000 20:30:46 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Discussion on my OOM killer API
Message-ID: <20001029203046.A23822@nightmaster.csn.tu-chemnitz.de>
References: <20001027191010.N18138@nightmaster.csn.tu-chemnitz.de> <Pine.LNX.4.10.10010271832020.13084-100000@dax.joh.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10010271832020.13084-100000@dax.joh.cam.ac.uk>; from jas88@cam.ac.uk on Fri, Oct 27, 2000 at 06:36:13PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Sutherland <jas88@cam.ac.uk>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 27, 2000 at 06:36:13PM +0100, James Sutherland wrote:
> > If I do the full blown variant of my patch: 
> EBADIDEA. The kernel's OOM killer is a last ditch "something's going to
> die - who's first?" - adding extra bloat like this is BAD.
 
Ok. So it's easier for me ;-)

> Policy should be decided user-side, and should prevent the kernel-side
> killer EVER triggering.
 
So your user space OOM handler would like to be notified on
memory *pressure* (not only about OOM)? You would like to shrink
image caches and the like with it? Sounds sane. 

But then we need information on _how_ much memory we need. I
could pass allocation "priority" to user space, but I doubt that
will be descriptive enough.

> I was planning to implement a user-side OOM killer myself - perhaps we
> could split the work, you do kernel-side, I'll do the userspace bits?

If you could clarify, what events you actually like to get, I
could implement this a loadable OOM handler.

But still my patch is much more flexible, since it even allows to
panic & reboot. I would prefer that on embedded systems, which
boot _really_ fast, over blowing the system by adding mutally
watching to my important processes.

Regards

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
