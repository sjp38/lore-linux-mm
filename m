Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA8386B0007
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:36:50 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f3-v6so13910753plf.1
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:36:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t8si10865053pgc.273.2018.03.26.15.36.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 15:36:49 -0700 (PDT)
Date: Mon, 26 Mar 2018 15:36:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 00/61] XArray v9
Message-Id: <20180326153648.27f53e9a1398812203745257@linux-foundation.org>
In-Reply-To: <20180313132639.17387-1-willy@infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Tue, 13 Mar 2018 06:25:38 -0700 Matthew Wilcox <willy@infradead.org> wrote:

> This patchset is, I believe, appropriate for merging for 4.17.
> It contains the XArray implementation, to eventually replace the radix
> tree, and converts the page cache to use it.

I looked at this from a for-4.17 POV and ran out of nerve at "[PATCH v9
09/61] xarray: Replace exceptional entries".  It's awfully late.

"[PATCH v9 08/61] page cache: Use xa_lock" looks sufficiently
mechanical to be if-it-compiles-it-works, although perhaps that
shouldn't be in 4.17 either.  Mainly because it commits us to merging
the rest of XArray and there hasn't been a ton of review and test
activity.



It looks like btrfs has changed in -next:

--- a/fs/btrfs/inode.c~page-cache-use-xa_lock-fix
+++ a/fs/btrfs/inode.c
@@ -7445,7 +7445,7 @@ out:
 
 bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
 {
-	struct radix_tree_root *root = &inode->i_mapping->page_tree;
+	struct radix_tree_root *root = &inode->i_mapping->i_pages;
 	bool found = false;
 	void **pagep = NULL;
 	struct page *page = NULL;
_
