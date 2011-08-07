Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 52F9E900137
	for <linux-mm@kvack.org>; Sun,  7 Aug 2011 10:27:42 -0400 (EDT)
Received: by pzk6 with SMTP id 6so1219876pzk.36
        for <linux-mm@kvack.org>; Sun, 07 Aug 2011 07:27:40 -0700 (PDT)
Date: Sun, 7 Aug 2011 23:27:29 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] readahead: add comments on PG_readahead
Message-ID: <20110807142729.GA2055@barrios-desktop>
References: <20110805035040.GB11532@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110805035040.GB11532@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 05, 2011 at 11:50:40AM +0800, Wu Fengguang wrote:
> Add comments to clarify the easily misunderstood PG_readahead timing.
> 
> PG_readahead is a trigger to say, when you get this far, it's time to
> think about kicking off the _next_ readahead.            -- Hugh
> 
> CC: Hugh Dickins <hughd@google.com>
> CC: Matthew Wilcox <willy@linux.intel.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I expect it would be very helpful.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
