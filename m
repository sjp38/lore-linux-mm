Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A23C6B01D4
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 09:31:38 -0400 (EDT)
Date: Mon, 21 Jun 2010 15:31:11 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100621133110.GD3828@quack.suse.cz>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <1276856495.27822.1697.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276856495.27822.1697.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Fri 18-06-10 12:21:35, Peter Zijlstra wrote:
> On Thu, 2010-06-17 at 20:04 +0200, Jan Kara wrote:
> > +                       /*
> > +                        * Now we can wakeup the writer which frees wc entry
> > +                        * The barrier is here so that woken task sees the
> > +                        * modification of wc.
> > +                        */
> > +                       smp_wmb();
> > +                       __wake_up_locked(&bdi->wb_written_wait, TASK_NORMAL); 
> 
> wakeups imply a wmb.
  Thanks. Removed smp_wmb and updated comment.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
