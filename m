Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B209E6B0038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 22:04:21 -0400 (EDT)
Received: by padck2 with SMTP id ck2so22631930pad.0
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 19:04:21 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id bz4si2485448pbd.70.2015.08.04.19.04.18
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 19:04:20 -0700 (PDT)
Date: Wed, 5 Aug 2015 12:03:57 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 04/11] ext4: Add ext4_get_block_dax()
Message-ID: <20150805020357.GA3902@dastard>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
 <1438718285-21168-5-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438718285-21168-5-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On Tue, Aug 04, 2015 at 03:57:58PM -0400, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> DAX wants different semantics from any currently-existing ext4
> get_block callback.  Unlike ext4_get_block_write(), it needs to honour
> the 'create' flag, and unlike ext4_get_block(), it needs to be able
> to return unwritten extents.  So introduce a new ext4_get_block_dax()
> which has those semantics.  We could also change ext4_get_block_write()
> to honour the 'create' flag, but that might have consequences on other
> users that I do not currently understand.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

Doesn't this make the first patch in the series redundant?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
