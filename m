From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [RFC] [RFT] [PATCH] memory zone balancing
In-Reply-To: <200001040227.SAA98076@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10001040417340.654-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Date: Tue, 4 Jan 2000 04:23:31 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Jan 100, Kanoj Sarcar wrote:

> Okay, here is a reworked version. Note that this version does not
> do per-zone balancing, since experiments show that we need to tune
> per-zone watermarks properly before we can start doing that. I am 
> working on coming up with a good estimate of per-zone watermarks.
> Basically, I am trying to answer the question: if there are d dmapages,
> r regular pages and h highmem pages, for a total of d+r+h pages, 
> what should the watermarks be for each zone?

d+r+h > limit
d     > limit/2
r     > limit/4
h     > limit/8

DMA pages should always be present, regular pages for
storing pagetables and stuff need to be there too, higmem
pages we don't really care about.

Btw, I think we probably want to increase freepages.min
to 512 or even more on machines that have >1GB of memory.
The current limit of 256 was really intended for machines
with a single zone of memory...

(but on <1GB machines I don't know if it makes sense to
raise the limit much more ... maybe we should raise the
limit automagically if the page alloc/io rate is too
high?)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
