Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0506B016B
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 18:24:55 -0400 (EDT)
Date: Wed, 31 Aug 2011 00:24:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/3 v3] writeback: Add writeback stats for pages written
Message-ID: <20110830222449.GJ16202@quack.suse.cz>
References: <1314038327-22645-1-git-send-email-curtw@google.com>
 <1314038327-22645-3-git-send-email-curtw@google.com>
 <20110829163645.GG5672@quack.suse.cz>
 <CAO81RMbyXvz214mTvjEg3NBpJ01JUw8+Goux4NoWZrZ_RCzLrA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAO81RMbyXvz214mTvjEg3NBpJ01JUw8+Goux4NoWZrZ_RCzLrA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue 30-08-11 11:13:50, Curt Wohlgemuth wrote:
> Hi Jan:
> 
> >> +static const char *wb_stats_labels[WB_REASON_MAX] = {
> >> +     [WB_REASON_BALANCE_DIRTY] = "page: balance_dirty_pages",
> >> +     [WB_REASON_BACKGROUND] = "page: background_writeout",
> >> +     [WB_REASON_TRY_TO_FREE_PAGES] = "page: try_to_free_pages",
> >> +     [WB_REASON_SYNC] = "page: sync",
> >> +     [WB_REASON_PERIODIC] = "page: periodic",
> >> +     [WB_REASON_FDATAWRITE] = "page: fdatawrite",
> >> +     [WB_REASON_LAPTOP_TIMER] = "page: laptop_periodic",
> >> +     [WB_REASON_FREE_MORE_MEM] = "page: free_more_memory",
> >> +     [WB_REASON_FS_FREE_SPACE] = "page: fs_free_space",
> >> +};
> >  I don't think it's good to have two enum->string translation tables for
> > reasons. That's prone to errors which is in fact proven by the fact that
> > you ommitted FORKER_THREAD reason here.
> 
> Ah, thanks for catching the omitted reason.  I assume you mean the
> table above, and
> 
>    +#define show_work_reason(reason)
> 
> from the patch 2/3 (in the trace events file).  Hmm, that could be a
> challenge, given the limitations on what you can do in trace macros.
> I'll think on this though.
  Ah right, with trace points it's not so simple. I guess we could have
an array with labels as a global symbol and dereference it in tracepoints.

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
