Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A864C6B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 04:52:11 -0500 (EST)
Date: Thu, 24 Nov 2011 09:52:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, debug: test for online nid when allocating on single
 node
Message-ID: <20111124095205.GQ19415@suse.de>
References: <alpine.DEB.2.00.1111221724550.18644@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111221724550.18644@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Nov 22, 2011 at 05:26:05PM -0800, David Rientjes wrote:
> Calling alloc_pages_exact_node() means the allocation only passes the
> zonelist of a single node into the page allocator.  If that node isn't
> online, it's zonelist may never have been initialized causing a strange
> oops that may not immediately be clear.
> 
> I recently debugged an issue where node 0 wasn't online and an allocator
> was passing 0 to alloc_pages_exact_node() and it resulted in a NULL
> pointer on zonelist->_zoneref.  If CONFIG_DEBUG_VM is enabled, though, it
> would be nice to catch this a bit earlier.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

Out of curiousity, who was passing in the ID of an offline node to
alloc_pages_exact_node() ?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
