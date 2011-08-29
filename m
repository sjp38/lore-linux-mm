Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DF45C900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 12:34:28 -0400 (EDT)
Date: Mon, 29 Aug 2011 18:34:25 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/3 v3] writeback: Add a 'reason' to wb_writeback_work
Message-ID: <20110829163425.GF5672@quack.suse.cz>
References: <1314038327-22645-1-git-send-email-curtw@google.com>
 <1314038327-22645-2-git-send-email-curtw@google.com>
 <20110829162313.GE5672@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110829162313.GE5672@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon 29-08-11 18:23:13, Jan Kara wrote:
> On Mon 22-08-11 11:38:46, Curt Wohlgemuth wrote:
> > This creates a new 'reason' field in a wb_writeback_work
> > structure, which unambiguously identifies who initiates
> > writeback activity.  A 'wb_reason' enumeration has been
> > added to writeback.h, to enumerate the possible reasons.
> > 
> > The 'writeback_work_class' and tracepoint event class and
> > 'writeback_queue_io' tracepoints are updated to include the
> > symbolic 'reason' in all trace events.
> > 
> > And the 'writeback_inodes_sbXXX' family of routines has had
> > a wb_stats parameter added to them, so callers can specify
> > why writeback is being started.
>   Looks good. You can add: Acked-by: Jan Kara <jack@suse.cz>
  Oh, one small typo correction:

> > +#define show_work_reason(reason)					\
> > +	__print_symbolic(reason,					\
> > +		{WB_REASON_BALANCE_DIRTY,	"balance_dirty"},	\
> > +		{WB_REASON_BACKGROUND,		"background"},		\
> > +		{WB_REASON_TRY_TO_FREE_PAGES,	"try_to_free_pages"},	\
> > +		{WB_REASON_SYNC,		"sync"},		\
> > +		{WB_REASON_PERIODIC,		"periodic"},		\
> > +		{WB_REASON_LAPTOP_TIMER,	"laptop_timer"},	\
> > +		{WB_REASON_FREE_MORE_MEM,	"free_more_memory"},	\
> > +		{WB_REASON_FS_FREE_SPACE,	"FS_free_space"},	\
                                                 ^^ should be in
non-capital letters?

> > +		{WB_REASON_FORKER_THREAD,	"forker_thread"}	\
> > +	)

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
