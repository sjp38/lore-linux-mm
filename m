Message-ID: <39217965.D0F64411@norran.net>
Date: Tue, 16 May 2000 18:37:57 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: Estrange behaviour of pre9-1
References: <Pine.LNX.4.10.10005160642440.1398-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On 16 May 2000, Juan J. Quintela wrote:
> > Hi
> >
> > linus> That is indeed what my shink_mmap() suggested change does (ie make
> > linus> "sync_page_buffers()" wait for old locked buffers).
> >
> > But your change wait for *all* locked buffers, I want to start several
> > writes asynchronously and then wait for one of them.
> 
> This is pretty much exactly what my change does - no need to be
> excessively clever.
> 
> Remember, we walk the LRU list from the "old" end, and whenever we hita
> dirty buffer we will write it out asynchronously. AND WE WILL MOVE IT TO
> THE TOP OF THE LRU QUEUE!
> 

Not in my recently released patch [Improved LRU shrink_mmap...].
It keeps the dirty (to be cleaned) pages in the old end.
I do not scan for dirty pages but it can easily be added - tonight.

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
