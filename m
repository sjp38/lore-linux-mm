Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E96F26B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 08:08:16 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1RDEeU-0000Wk-JC
	for linux-mm@kvack.org; Mon, 10 Oct 2011 12:08:14 +0000
Subject: Re: [PATCH 00/11] IO-less dirty throttling v12
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20111003134228.090592370@intel.com>
References: <20111003134228.090592370@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 Oct 2011 14:14:06 +0200
Message-ID: <1318248846.14400.21.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 2011-10-03 at 21:42 +0800, Wu Fengguang wrote:
> This is the minimal IO-less balance_dirty_pages() changes that are expected to
> be regression free (well, except for NFS).

I can't seem to get around reviewing these patches in detail, but fwiw
I'm fine with pushing fwd with this set (plus a possible NFS fix).

I don't see a reason to strip it down even further.

So I guess that's:

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
