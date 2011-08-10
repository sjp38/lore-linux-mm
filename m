Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5A4CF6B00EE
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 23:23:04 -0400 (EDT)
Date: Wed, 10 Aug 2011 11:22:49 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110810032249.GA24486@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094527.136636891@intel.com>
 <20110809181543.GG6482@redhat.com>
 <1312915266.1083.75.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312915266.1083.75.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 10, 2011 at 02:41:05AM +0800, Peter Zijlstra wrote:
> On Tue, 2011-08-09 at 14:15 -0400, Vivek Goyal wrote:
> > 
> > So far bw had pos_ratio as value now it will be replaced with actual
> > bandwidth as value. It makes code confusing. So using pos_ratio will
> > help. 
> 
> Agreed on consistency, also I'm not sure bandwidth is the right term
> here to begin with, its a pages/s unit and I think rate would be better
> here. But whatever ;-)

Good idea, I'll switch to the name "rate".

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
