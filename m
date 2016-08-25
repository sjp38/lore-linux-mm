Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D771883093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 15:25:34 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so92383780pad.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 12:25:34 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f66si16856679pfc.168.2016.08.25.12.25.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 12:25:33 -0700 (PDT)
Date: Thu, 25 Aug 2016 13:25:31 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160825192531.GA2607@linux.intel.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160825075728.GA11235@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm@ml01.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Thu, Aug 25, 2016 at 12:57:28AM -0700, Christoph Hellwig wrote:
> Hi Ross,
> 
> can you take at my (fully working, but not fully cleaned up) version
> of the iomap based DAX code here:
> 
> http://git.infradead.org/users/hch/vfs.git/shortlog/refs/heads/iomap-dax
> 
> By using iomap we don't even have the size hole problem and totally
> get out of the reverse-engineer what buffer_heads are trying to tell
> us business.  It also gets rid of the other warts of the DAX path
> due to pretending to be like direct I/O, so this might be a better
> way forward also for ext2/4.

Sure, I'll take a look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
