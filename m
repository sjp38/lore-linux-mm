Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 944156B0253
	for <linux-mm@kvack.org>; Tue,  3 May 2016 16:28:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 77so61589251pfz.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 13:28:59 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id t25si231459pfa.5.2016.05.03.13.28.58
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 13:28:58 -0700 (PDT)
Date: Tue, 3 May 2016 14:28:57 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH mmotm] radix-tree: rewrite radix_tree_locate_item fix
Message-ID: <20160503202857.GA3997@linux.intel.com>
References: <alpine.LSU.2.11.1605012108490.1166@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1605012108490.1166@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, May 01, 2016 at 09:13:18PM -0700, Hugh Dickins wrote:
> radix_tree_locate_item() is often returning the wrong index, causing
> swapoff of shmem to hang because it cannot find the swap entry there.
> __locate()'s use of base is bogus, it adds an offset twice into index.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thank you for the fix!

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
