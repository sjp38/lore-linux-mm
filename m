Message-ID: <44ED1093.3050905@yahoo.com.au>
Date: Thu, 24 Aug 2006 12:36:03 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] radix-tree:  fix radix_tree_replace_slot
References: <1156278317.5622.14.camel@localhost>
In-Reply-To: <1156278317.5622.14.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@osdl.org>, "Paul E. McKenney" <paulmck@us.ibm.com>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> I was waiting to hear from Nick on this, but I understand that he has
> severely injured one hand, restricting his keyboard access for a while. 

Yeah sorry Lee, ping times have gone up and throughput down.

This does look like the right fix to me. Thanks very much for tracking
it down. Both these patches are

Acked-by: Nick Piggin <npiggin@suse.de>

BTW. I'll have to do a little rework on the radix tree to get the
lockless pagecache patches working properly after the direct-data
patches (based on review feedback)... that will take me a while :(

In the meantime, RCU radix tree isn't getting any lock-free testing
because everything still takes tree_lock... I wonder if Andrew would
be brave enough to lift the tree_lock from mm/readahead.c ?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
