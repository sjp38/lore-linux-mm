Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6A16B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 11:19:07 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so6601946pab.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 08:19:07 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id q6si5769100pdm.185.2015.08.05.08.19.06
        for <linux-mm@kvack.org>;
        Wed, 05 Aug 2015 08:19:06 -0700 (PDT)
Date: Wed, 5 Aug 2015 11:19:04 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 04/11] ext4: Add ext4_get_block_dax()
Message-ID: <20150805151904.GD13681@linux.intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
 <1438718285-21168-5-git-send-email-matthew.r.wilcox@intel.com>
 <20150805020357.GA3902@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150805020357.GA3902@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 05, 2015 at 12:03:57PM +1000, Dave Chinner wrote:
> On Tue, Aug 04, 2015 at 03:57:58PM -0400, Matthew Wilcox wrote:
> > From: Matthew Wilcox <willy@linux.intel.com>
> > 
> > DAX wants different semantics from any currently-existing ext4
> > get_block callback.  Unlike ext4_get_block_write(), it needs to honour
> > the 'create' flag, and unlike ext4_get_block(), it needs to be able
> > to return unwritten extents.  So introduce a new ext4_get_block_dax()
> > which has those semantics.  We could also change ext4_get_block_write()
> > to honour the 'create' flag, but that might have consequences on other
> > users that I do not currently understand.
> > 
> > Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> 
> Doesn't this make the first patch in the series redundant?

As I explained in the cover letter, patch 1 already went to Ted.  It might
be on its way in, and it might not.  Rather than sending a patch that
applies to current mainline and forcing someone to fix up a conflict
later, better to resend the patch as part of this series, and our tools
will do the right thing no matter which order patches go into Linus' tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
