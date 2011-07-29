Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 651EC6B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 07:05:17 -0400 (EDT)
Date: Fri, 29 Jul 2011 12:05:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 0/5] mm: per-zone dirty limiting
Message-ID: <20110729110510.GS3010@suse.de>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <20110726154741.GE3010@suse.de>
 <20110726180559.GA667@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110726180559.GA667@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, Jul 26, 2011 at 08:05:59PM +0200, Johannes Weiner wrote:
> > As dd is variable, I'm rerunning the tests to do 4 iterations and
> > multiple memory sizes for just xfs and ext4 to see what falls out. It
> > should take about 14 hours to complete assuming nothing screws up.
> 
> Awesome, thanks!
> 

While they in fact took about 30 hours to complete, I only got around
to packaging them up now. Unfortuantely the tests were incomplete as
I needed the machine back for another use but the results that did
complete are at http://www.csn.ul.ie/~mel/postings/hnaz-20110729/

Look for the comparison.html files such as this one

http://www.csn.ul.ie/~mel/postings/hnaz-20110729/global-dhp-512M__writeback-reclaimdirty-ext3/hydra/comparison.html

I'm afraid I haven't looked through them in detail.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
