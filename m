Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D3F629000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:09:47 -0400 (EDT)
Date: Wed, 21 Sep 2011 16:09:35 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 3/4] mm: filemap: pass __GFP_WRITE from
 grab_cache_page_write_begin()
Message-ID: <20110921140935.GF22516@redhat.com>
References: <1316526315-16801-1-git-send-email-jweiner@redhat.com>
 <1316526315-16801-4-git-send-email-jweiner@redhat.com>
 <20110920142553.GA2593@infradead.org>
 <4E78DD8B.1020605@redhat.com>
 <20110920184034.GA27353@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920184034.GA27353@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 20, 2011 at 02:40:34PM -0400, Christoph Hellwig wrote:
> On Tue, Sep 20, 2011 at 02:38:03PM -0400, Rik van Riel wrote:
> > On 09/20/2011 10:25 AM, Christoph Hellwig wrote:
> > >In addition to regular write shouldn't __do_fault and do_wp_page also
> > >calls this if they are called on file backed mappings?
> > 
> > Probably not do_wp_page since it always creates an
> > anonymous page, which are not very relevant to the
> > dirty page cache accounting.
> 
> Well, it doesn't always - but for the case where it doesn't we
> do not allocate a new page at all so you're right in the end :)

I think it could be useful to annotate write-fault allocations in
filemap_fault(), but these pages are mostly allocated in the readahead
code, so this could turn into a more invasive project.

It can be done incrementally, however, the series as it stands does
not require it to be useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
