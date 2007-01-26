Message-ID: <45B9F3A3.6080003@yahoo.com.au>
Date: Fri, 26 Jan 2007 23:27:15 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] Add __GFP_MOVABLE for callers to flag allocations
 that may be migrated
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie> <20070125234518.28809.86069.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070125234518.28809.86069.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> It is often known at allocation time when a page may be migrated or
> not. This patch adds a flag called __GFP_MOVABLE and a new mask called
> GFP_HIGH_MOVABLE.

Shouldn't that be HIGHUSER_MOVABLE?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
