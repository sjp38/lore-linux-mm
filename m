Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 771AA6B0078
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 16:37:27 -0500 (EST)
Subject: Re: [PATCH 4/7] Memory compaction core
From: Andi Kleen <andi@firstfloor.org>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie>
	<1262795169-9095-5-git-send-email-mel@csn.ul.ie>
Date: Wed, 06 Jan 2010 22:37:22 +0100
In-Reply-To: <1262795169-9095-5-git-send-email-mel@csn.ul.ie> (Mel Gorman's message of "Wed,  6 Jan 2010 16:26:06 +0000")
Message-ID: <87iqbeykx9.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman <mel@csn.ul.ie> writes:


Haven't reviewed the full thing, but one thing I noticed below:

> +
> +	/*
> +	 * Isolate free pages until enough are available to migrate the
> +	 * pages on cc->migratepages. We stop searching if the migrate
> +	 * and free page scanners meet or enough free pages are isolated.
> +	 */
> +	spin_lock_irq(&zone->lock);

Won't that cause very long lock hold times on large zones?
Presumably you need some kind of lock break heuristic.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
