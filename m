Date: Thu, 6 Jan 2000 17:05:41 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [RFC] [RFT] [PATCH] memory zone balancing
In-Reply-To: <200001040227.SAA98076@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10001061701160.5892-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, torvalds@transmeta.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Jan 100, Kanoj Sarcar wrote:

> Okay, here is a reworked version. Note that this version does not
> do per-zone balancing, since experiments show that we need to tune
> per-zone watermarks properly before we can start doing that. I am 
> working on coming up with a good estimate of per-zone watermarks.
> Basically, I am trying to answer the question: if there are d dmapages,
> r regular pages and h highmem pages, for a total of d+r+h pages, 
> what should the watermarks be for each zone?

i think this is pretty much 'type-dependent'. In earlier versions of the
zone allocator i added a zone->memory_balanced() function (but removed it
later because it first needed the things your patch adds). Then every zone
can decide for itself wether it's balanced. Eg. the DMA zone is rather
critical and we want to keep it free aggressively (part of that is already
achieved by placing it at the end of the zone chain), the highmem zone
might not need any balancing at all, the normal zone wants some high/low
watermark stuff.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
