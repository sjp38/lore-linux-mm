Date: Thu, 11 Jul 2002 17:54:22 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Optimize out pte_chain take three
In-Reply-To: <3D2DEDAD.A38AFF25@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207111750050.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jul 2002, Andrew Morton wrote:
> Rik van Riel wrote:
> > ...
> > > useful pagecache and swapping everything out.  Our kernels have
> > > O_STREAMING because of this.   It simply removes as much pagecache
> > > as it can, each time ->nrpages reaches 256.  It's rather effective.
> >
> > Now why does that remind me of drop-behind ? ;)
>
> I looked at 2.4-ac as well.  Seems that the dropbehind there only
> addresses reads?

It should also work on linear writes.


> I suspect the best fix here is to not have dirty or writeback
> pagecache pages on the LRU at all.  Throttle on memory coming
> reclaimable, put the pages back on the LRU when they're clean,
> etc.  As we have often discussed.  Big change.

That just doesn't make sense, if you don't put the dirty pages
on the LRU then what incentive _do_ you have to write them out ?

Will you start writing them out once you run out of clean pages ?

Will you reclaim all glibc mapped pages before writing out dirty
pages ?

If the throttling is wrong, I propose we fix the trottling.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
