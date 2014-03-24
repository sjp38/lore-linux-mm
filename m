Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9CEFD6B0035
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 15:12:08 -0400 (EDT)
Received: by mail-yh0-f52.google.com with SMTP id c41so5636749yho.39
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 12:12:08 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id q67si16447776yhe.172.2014.03.24.12.12.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 12:12:08 -0700 (PDT)
Date: Mon, 24 Mar 2014 15:11:59 -0400
From: tytso@mit.edu
Subject: Re: [PATCH v7 19/22] ext4: Make ext4_block_zero_page_range static
Message-ID: <20140324191158.GC6896@thunk.org>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <6ae0bcd05c2e114d3c4a7803415b6c2c8a8dadd7.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6ae0bcd05c2e114d3c4a7803415b6c2c8a8dadd7.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com, linux-ext4@vger.kernel.org

On Sun, Mar 23, 2014 at 03:08:45PM -0400, Matthew Wilcox wrote:
> It's only called within inode.c, so make it static, remove its prototype
> from ext4.h and move it above all of its callers so it doesn't need a
> prototype within inode.c.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>

Thanks, applied to the ext4 tree.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
