Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 648D66B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 03:40:03 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id s9so397255wrc.16
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 00:40:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 136si10244713wmj.207.2017.10.11.00.40.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 00:40:02 -0700 (PDT)
Date: Wed, 11 Oct 2017 08:39:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/7] mm: Batch radix tree operations when truncating pages
Message-ID: <20171011073959.tvajcejxho7g7zw2@suse.de>
References: <20171010151937.26984-1-jack@suse.cz>
 <20171010151937.26984-8-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171010151937.26984-8-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

On Tue, Oct 10, 2017 at 05:19:37PM +0200, Jan Kara wrote:
> Currently we remove pages from the radix tree one by one. To speed up
> page cache truncation, lock several pages at once and free them in one
> go. This allows us to batch radix tree operations in a more efficient
> way and also save round-trips on mapping->tree_lock. As a result we gain
> about 20% speed improvement in page cache truncation.
> 
> Data from a simple benchmark timing 10000 truncates of 1024 pages (on
> ext4 on ramdisk but the filesystem is barely visible in the profiles).
> The range shows 1% and 95% percentiles of the measured times:
> 
> 4.14-rc2	4.14-rc2 + batched truncation
> 248-256		209-219
> 249-258		209-217
> 248-255		211-239
> 248-255		209-217
> 247-256		210-218
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
