Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AA20D8D0042
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:16:00 -0500 (EST)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1PlLW2-0005DP-GR
	for linux-mm@kvack.org; Fri, 04 Feb 2011 13:15:58 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PlLW1-0001mt-In
	for linux-mm@kvack.org; Fri, 04 Feb 2011 13:15:57 +0000
Subject: Re: [PATCH 5/5] mm: Autotune interval between distribution of page
 completions
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1296783534-11585-6-git-send-email-jack@suse.cz>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
	 <1296783534-11585-6-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Feb 2011 14:09:18 +0100
Message-ID: <1296824958.26581.651.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>

On Fri, 2011-02-04 at 02:38 +0100, Jan Kara wrote:
> +       unsigned long pages_per_s;      /* estimated throughput of bdi */

isn't that typically called bandwidth?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
