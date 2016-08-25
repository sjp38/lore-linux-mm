Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9ADB6B0274
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:57:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so77385535pfg.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 00:57:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id p184si14249995pfb.299.2016.08.25.00.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 00:57:32 -0700 (PDT)
Date: Thu, 25 Aug 2016 00:57:28 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160825075728.GA11235@infradead.org>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823220419.11717-3-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm@ml01.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

Hi Ross,

can you take at my (fully working, but not fully cleaned up) version
of the iomap based DAX code here:

http://git.infradead.org/users/hch/vfs.git/shortlog/refs/heads/iomap-dax

By using iomap we don't even have the size hole problem and totally
get out of the reverse-engineer what buffer_heads are trying to tell
us business.  It also gets rid of the other warts of the DAX path
due to pretending to be like direct I/O, so this might be a better
way forward also for ext2/4.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
