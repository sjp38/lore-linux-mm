Message-ID: <39126DB2.2DD7CAB3@sgi.com>
Date: Thu, 04 May 2000 23:44:02 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: 7-4 VM killing (A solution)
References: <Pine.LNX.4.10.10005042212480.1156-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: riel@nl.linux.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:
> >
> > Ok, I may have a solution after having asked, mostly to myself,
> > why doesn't shrink_mmap() find pages to free?
> >
> > The answer apparenlty is because in 7-4 shrink_mmap(),
> > unreferenced pages get filed as "young" if the zone has
> > enough pages in it (free_pages > pages_high).
> 
> Good catch.
> 
> That's obviously a bug, and your fix looks like the obvious fix. Thanks,

Rik still had some reservations although he hasn't
sent a response to my rebuttal, yet. We'll see see.

On another note, noticed your change to shrink_mmap in 7-5:

-------
-       count = nr_lru_pages >> priority;
+       count = (nr_lru_pages << 1) >> priority;
-------

Is this to defeat aging? If so, I think its overly cautious:
if all an iteration of shrink_mmap did was to flip the referenced bit,
then that iteration shouldn't be included in count (and in the
current code it isn't). So why double the effort?

-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
