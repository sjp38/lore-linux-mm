Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA736B017A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 05:17:35 -0400 (EDT)
Date: Tue, 23 Aug 2011 05:17:32 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 05/13] mm: convert shrinkers to use new API
Message-ID: <20110823091732.GD21492@infradead.org>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
 <1314089786-20535-6-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314089786-20535-6-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

On Tue, Aug 23, 2011 at 06:56:18PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Modify shrink_slab() to use the new .count_objects/.scan_objects API
> and implement the callouts for all the existing shrinkers.

The split between this and the previous patch isn't obvious to me.
Either we'll do the whole switchover in one patch, or add the new
API fully in a first one and convert them one for one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
