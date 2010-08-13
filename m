Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 19F7C6B01F0
	for <linux-mm@kvack.org>; Fri, 13 Aug 2010 03:51:08 -0400 (EDT)
Date: Fri, 13 Aug 2010 03:50:59 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] mm: Implement writeback livelock avoidance using
 page tagging
Message-ID: <20100813075059.GA4122@infradead.org>
References: <1275677231-15662-1-git-send-email-jack@suse.cz>
 <1275677231-15662-3-git-send-email-jack@suse.cz>
 <20100812183547.GA2294@infradead.org>
 <20100812222857.GC3665@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100812222857.GC3665@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 13, 2010 at 12:28:58AM +0200, Jan Kara wrote:
>   And from the values in registers the loop seems to have went astray
> because "index" was zero at the point we entered the loop... looking
> around...  Ah, I see, you create files with 16TB size which creates
> radix tree of such height that radix_tree_maxindex(height) == ~0UL and
> if write_cache_pages() passes in ~0UL as end, we can overflow the index.
> Hmm, I haven't realized that is possible.
>   OK, attached is a patch that should fix the issue.

This seems to fix the case for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
