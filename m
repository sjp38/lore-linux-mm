Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5F40C6B01F8
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 10:57:28 -0400 (EDT)
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
From: Andi Kleen <andi@firstfloor.org>
References: <20100413202021.GZ13327@think> <20100414014041.GD2493@dastard>
	<20100414155233.D153.A69D9226@jp.fujitsu.com>
	<20100414072830.GK2493@dastard> <20100414085132.GJ25756@csn.ul.ie>
	<20100415013436.GO2493@dastard>
Date: Thu, 15 Apr 2010 16:57:20 +0200
In-Reply-To: <20100415013436.GO2493@dastard> (Dave Chinner's message of "Thu, 15 Apr 2010 11:34:36 +1000")
Message-ID: <87y6go931r.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave Chinner <david@fromorbit.com> writes:
>
> How about this? For now, we stop direct reclaim from doing writeback
> only on order zero allocations, but allow it for higher order
> allocations. That will prevent the majority of situations where

And also stop it always with 4K stacks.

> direct reclaim blows the stack and interferes with background
> writeout, but won't cause lumpy reclaim to change behaviour.
> This reduces the scope of impact and hence testing and validation
> the needs to be done.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
