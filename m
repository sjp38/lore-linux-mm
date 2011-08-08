Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6A5046B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 18:38:10 -0400 (EDT)
Date: Tue, 9 Aug 2011 06:38:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
Message-ID: <20110808223805.GA7176@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094527.002914580@intel.com>
 <1312811234.10488.34.camel@twins>
 <20110808142318.GC22080@localhost>
 <1312813612.10488.36.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312813612.10488.36.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 08, 2011 at 10:26:52PM +0800, Peter Zijlstra wrote:
> On Mon, 2011-08-08 at 22:23 +0800, Wu Fengguang wrote:
> > +       preempt_disable();
> > +       p = &__get_cpu_var(dirty_leaks);
> 
>  p = &get_cpu_var(dirty_leaks);
> 
> > +       if (*p > 0 && current->nr_dirtied < ratelimit) {
> > +               nr_pages_dirtied = min(*p, ratelimit - current->nr_dirtied);
> > +               *p -= nr_pages_dirtied;
> > +               current->nr_dirtied += nr_pages_dirtied;
> > +       }
> > +       preempt_enable(); 
> 
> put_cpu_var(dirty_leads);

Good to know these, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
