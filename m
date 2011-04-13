Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1432F900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 06:13:25 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1Q9x4d-00056A-36
	for linux-mm@kvack.org; Wed, 13 Apr 2011 10:13:23 +0000
Subject: Re: [PATCH 0/4] trivial writeback fixes
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110413085937.981293444@intel.com>
References: <20110413085937.981293444@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 13 Apr 2011 12:15:49 +0200
Message-ID: <1302689749.2035.3.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

On Wed, 2011-04-13 at 16:59 +0800, Wu Fengguang wrote:
> Andrew,
> 
> Here are four trivial writeback fix patches that
> should work well for the patches from both Jan and me.

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
