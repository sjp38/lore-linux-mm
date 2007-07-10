Message-ID: <46935CEB.3050204@yahoo.com.au>
Date: Tue, 10 Jul 2007 20:18:19 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: zone movable patches comments
References: <4691E8D1.4030507@yahoo.com.au> <20070709110457.GB9305@skynet.ie> <469226CB.4010900@yahoo.com.au> <20070709132140.GC9305@skynet.ie> <46933BD7.2020200@yahoo.com.au> <20070710095116.GB12052@skynet.ie> <46935C84.9060407@yahoo.com.au>
In-Reply-To: <46935C84.9060407@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@skynet.ie>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> I'm not completely against kernelcore=, no. However I do think that
> should be a general parameter that exists for the core kernel. I guess it
> would override any other reservations and things, and it would specify the
> absolute minimum kernelcore.
> 
> Then if you add a movable_mem= (or something -- I don't know what the
> exact name should be), then that would also specify the minimum movable
> memory, although at a lower priority to kernelcore= (and you could have
> the appropriate warnings and such if they cannot be satisfied).

Ah yes, I now read Andy's mail and this is what he is suggesting, so
yes it seems like a good idea I think.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
