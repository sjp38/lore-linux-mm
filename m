Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5756B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 12:51:05 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id bk3so27596035wjc.4
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 09:51:05 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b79si29375230wma.103.2016.12.12.09.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 09:51:04 -0800 (PST)
Date: Mon, 12 Dec 2016 12:50:55 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/6] mm: Invalidate DAX radix tree entries only if
 appropriate
Message-ID: <20161212175054.GA8688@cmpxchg.org>
References: <20161212164708.23244-1-jack@suse.cz>
 <20161212164708.23244-3-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161212164708.23244-3-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Mon, Dec 12, 2016 at 05:47:04PM +0100, Jan Kara wrote:
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
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
