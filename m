Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E9F4F6B01D7
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 09:43:06 -0400 (EDT)
Date: Mon, 21 Jun 2010 15:42:39 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100621134238.GE3828@quack.suse.cz>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <1276856497.27822.1699.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276856497.27822.1699.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Fri 18-06-10 12:21:37, Peter Zijlstra wrote:
> On Thu, 2010-06-17 at 20:04 +0200, Jan Kara wrote:
> > +               if (bdi_stat(bdi, BDI_WRITTEN) >= bdi->wb_written_head)
> > +                       bdi_wakeup_writers(bdi); 
> 
> For the paranoid amongst us you could make wb_written_head s64 and write
> the above as:
> 
>   if (bdi_stat(bdi, BDI_WRITTEN) - bdi->wb_written_head > 0)
> 
> Which, if you assume both are monotonic and wb_written_head is always
> within 2^63 of the actual bdi_stat() value, should give the same end
> result and deal with wrap-around.
> 
> For when we manage to create a device that can write 2^64 pages in our
> uptime :-)
  OK, the fix is simple enough so I've changed it, although I'm not
paranoic enough ;) (I actually did the math before writing that test).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
