Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 979316B0071
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 16:55:09 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so5708958pdi.2
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:55:09 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id o5si22499690pdh.194.2015.01.13.13.55.07
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 13:55:08 -0800 (PST)
Date: Tue, 13 Jan 2015 16:55:05 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v12 09/20] dax,ext2: Replace xip_truncate_page with
 dax_truncate_page
Message-ID: <20150113215505.GL5661@wil.cx>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <1414185652-28663-10-git-send-email-matthew.r.wilcox@intel.com>
 <20150112150958.2e6bd85dc3e25b953d28c6cb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112150958.2e6bd85dc3e25b953d28c6cb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Mon, Jan 12, 2015 at 03:09:58PM -0800, Andrew Morton wrote:
> > + * Similar to block_truncate_page(), this function can be called by a
> > + * filesystem when it is truncating an DAX file to handle the partial page.
> > + *
> > + * We work in terms of PAGE_CACHE_SIZE here for commonality with
> > + * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
> > + * took care of disposing of the unnecessary blocks.
> 
> But PAGE_SIZE==PAGE_CACHE_SIZE.  Unclear what you're saying here.

The last I heard, some people were trying to resurrect the PAGE_CACHE_SIZE
> PAGE_SIZE patches.  I'd be grateful if the distinction between PAGE_SIZE
and PAGE_CACHE_SIZE went away, tbh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
