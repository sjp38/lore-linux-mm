Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 784866B0085
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 05:44:42 -0500 (EST)
Date: Wed, 24 Nov 2010 18:44:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 05/13] writeback: account per-bdi accumulated written
 pages
Message-ID: <20101124104437.GB6096@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042849.884566722@intel.com>
 <1290594376.2072.442.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290594376.2072.442.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 06:26:16PM +0800, Peter Zijlstra wrote:
> On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> > @@ -1292,6 +1292,7 @@ int test_clear_page_writeback(struct pag
> >                                                 PAGECACHE_TAG_WRITEBACK);
> >                         if (bdi_cap_account_writeback(bdi)) {
> >                                 __dec_bdi_stat(bdi, BDI_WRITEBACK);
> > +                               __inc_bdi_stat(bdi, BDI_WRITTEN);
> >                                 __bdi_writeout_inc(bdi);
> >                         }
> >                 } 
> 
> Shouldn't that live in __bdi_writeout_inc()? It looks like this forgets
> about fuse (fuse_writepage_finish() -> bdi_writeout_inc() ->
> __bdi_writeout_inc()).

Good catch! Will fix it in next post.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
