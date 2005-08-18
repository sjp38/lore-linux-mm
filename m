Message-ID: <430448F8.3090502@yahoo.com.au>
Date: Thu, 18 Aug 2005 18:38:16 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: pagefault scalability patches
References: <20050817151723.48c948c7.akpm@osdl.org> <4303EBC2.4030603@yahoo.com.au>
In-Reply-To: <4303EBC2.4030603@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@engr.sgi.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> If the big ticket item is taking the ptl out of the anonymous fault
> path, then we probably should forget my stuff

( for now :) )

> and consider Christoph's
> on its own merits.
> 
> FWIW, I don't think it is an unreasonable approach to solving the
> problem at hand in a fairly unintrusive manner.
> 

To be clear: by "it" I mean Christoph's patches, not mine.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
