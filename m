Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DCD9D8D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 09:56:11 -0500 (EST)
Date: Fri, 11 Feb 2011 15:56:07 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
Message-ID: <20110211145607.GI5187@quack.suse.cz>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
 <1296783534-11585-4-git-send-email-jack@suse.cz>
 <1296824955.26581.645.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296824955.26581.645.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>

On Fri 04-02-11 14:09:15, Peter Zijlstra wrote:
> On Fri, 2011-02-04 at 02:38 +0100, Jan Kara wrote:
> > +struct balance_waiter {
> > +       struct list_head bw_list;
> > +       unsigned long bw_to_write;      /* Number of pages to wait for to
> > +                                          get written */
> 
> That names somehow rubs me the wrong way.. the name suggests we need to
> do the writing, whereas we only wait for them to be written.
  Good point. Will change that.

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
