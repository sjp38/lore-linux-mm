Message-ID: <429E4023.2010308@yahoo.com.au>
Date: Thu, 02 Jun 2005 09:09:23 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
References: <20050531112048.D2511E57A@skynet.csn.ul.ie> <429E20B6.2000907@austin.ibm.com>
In-Reply-To: <429E20B6.2000907@austin.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jschopp@austin.ibm.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Joel Schopp wrote:

> 
> Other than the very minor whitespace changes above I have nothing bad to 
> say about this patch.  I think it is about time to pick in up in -mm for 
> wider testing.
> 

It adds a lot of complexity to the page allocator and while
it might be very good, the only improvement we've been shown
yet is allocating lots of MAX_ORDER allocations I think? (ie.
not very useful)

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
