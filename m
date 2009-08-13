Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8FB436B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 13:45:31 -0400 (EDT)
Date: Thu, 13 Aug 2009 18:45:18 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] swap: send callback when swap slot is freed
In-Reply-To: <4A837AAF.4050103@vflare.org>
Message-ID: <Pine.LNX.4.64.0908131836270.14631@sister.anvils>
References: <200908122007.43522.ngupta@vflare.org>
 <Pine.LNX.4.64.0908122312380.25501@sister.anvils> <4A837AAF.4050103@vflare.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Aug 2009, Nitin Gupta wrote:
> On 08/13/2009 04:18 AM, Hugh Dickins wrote:
> 
> > But fundamentally, though I can see how this cutdown communication
> > path is useful to compcache, I'd much rather deal with it by the more
> > general discard route if we can.
> 
> I tried this too -- make discard bio request as soon as a swap slot becomes
> free (I can send details if you want). However, I could not get it to work.

I'll send you an updated version of what I experimented with eight
months ago: but changes in the swap_map count handling since then
mean that it might need some subtle adjustments - I'll need to go
over it carefully and retest before sending you.

(But that won't be a waste of my time: I shall soon need to try
that experiment again myself, and I do need to examine those
intervening swap_map count changes more closely.)

> Also, allocating bio to issue discard I/O request looks like a complete
> artifact in compcache case.

Yes, I do understand that feeling.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
