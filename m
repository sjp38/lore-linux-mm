Date: Mon, 2 Oct 2000 16:28:48 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] fix for VM test9-pre,
In-Reply-To: <20001002212521.A21473@athlon.random>
Message-ID: <Pine.LNX.4.21.0010021626460.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ying Chen/Almaden/IBM <ying@almaden.ibm.com>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Andrea Arcangeli wrote:
> On Mon, Oct 02, 2000 at 02:07:51PM -0300, Rik van Riel wrote:
> > However, I have no idea why your buffers and pagecache pages
> > aren't bounced into the HIGHMEM zone ... They /should/ just
> 
> buffers/dcache/icache can't be allocated in HIGHMEM zone. Only
> page cache can live in HIGHMEM by using bounce buffers for doing
> the I/O.

Yup, indeed. I guess we need some extra logic to prevent the
system from trying to fill all of low memory with dirty
pages just because all of the highmem pages are free.

(also, having more than say 200MB in the write-behind queue
probably doesn't make any sense)

> > be moved to the HIGHMEM zone where they don't bother the rest
> > of the system, but for some reason it looks like that doesn't
> > work right on your system ...
> 
> That shouldn't be the problem, the bounce buffer logic isn't
> changed since test6 that is reported not to show the bad
> behaviour.

Unfortunately, I DID get a few bug reports about
2.4.0-test6 and earlier kernels that DID show this
bug ...

I can dig out the bug report if you want ;)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
