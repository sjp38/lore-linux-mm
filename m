Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B1C6B8D003B
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 10:49:58 -0500 (EST)
Date: Fri, 11 Feb 2011 16:49:54 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/5] mm: Autotune interval between distribution of page
 completions
Message-ID: <20110211154954.GL5187@quack.suse.cz>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
 <1296783534-11585-6-git-send-email-jack@suse.cz>
 <1296824958.26581.651.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296824958.26581.651.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>

On Fri 04-02-11 14:09:18, Peter Zijlstra wrote:
> On Fri, 2011-02-04 at 02:38 +0100, Jan Kara wrote:
> > +       unsigned long pages_per_s;      /* estimated throughput of bdi */
> 
> isn't that typically called bandwidth?
  Yes, but this name gives you information about the units (and bandwidth
isn't much shorter ;). But I'll happily go with bandwidth if you think it's
better.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
