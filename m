Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2348D0040
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:18:52 -0500 (EST)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PlLYn-0003me-F4
	for linux-mm@kvack.org; Fri, 04 Feb 2011 13:18:49 +0000
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1296824956.26581.649.camel@laptop>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
	 <1296783534-11585-4-git-send-email-jack@suse.cz>
	 <1296824956.26581.649.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Feb 2011 14:19:52 +0100
Message-ID: <1296825592.26581.654.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>

On Fri, 2011-02-04 at 14:09 +0100, Peter Zijlstra wrote:
> 
> You can do that by keeping ->bw_to_write in task_struct and normalize it
> by the estimated bdi bandwidth (patch 5), that way, when you next
> increment it it will turn out to be lower and the wait will be shorter.

The down-side is of course that time will leak from the system on exit,
since its impossible to map back to a bdi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
