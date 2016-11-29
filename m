Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2F946B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:17:58 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f188so457746131pgc.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:17:58 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 8si61584415pfu.111.2016.11.29.14.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 14:17:58 -0800 (PST)
Date: Tue, 29 Nov 2016 15:17:57 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/6] mm: Invalidate DAX radix tree entries only if
 appropriate
Message-ID: <20161129221757.GA16608@linux.intel.com>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
 <1479980796-26161-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479980796-26161-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Nov 24, 2016 at 10:46:32AM +0100, Jan Kara wrote:
> Currently invalidate_inode_pages2_range() and invalidate_mapping_pages()
> just delete all exceptional radix tree entries they find. For DAX this
> is not desirable as we track cache dirtiness in these entries and when
> they are evicted, we may not flush caches although it is necessary. This
> can for example manifest when we write to the same block both via mmap
> and via write(2) (to different offsets) and fsync(2) then does not
> properly flush CPU caches when modification via write(2) was the last
> one.
> 
> Create appropriate DAX functions to handle invalidation of DAX entries
> for invalidate_inode_pages2_range() and invalidate_mapping_pages() and
> wire them up into the corresponding mm functions.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

For the DAX bits:
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
