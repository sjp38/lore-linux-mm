Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAA2830EF
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 08:57:46 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 93so296279119qtg.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 05:57:46 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id a66si9539746ywg.192.2016.08.29.05.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 05:57:45 -0700 (PDT)
Date: Mon, 29 Aug 2016 08:57:41 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160829125741.cdnbb2uaditcmnw2@thunk.org>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
 <20160829074116.GA16491@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160829074116.GA16491@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm@ml01.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Mon, Aug 29, 2016 at 12:41:16AM -0700, Christoph Hellwig wrote:
> 
> We're going to move forward killing buffer_heads in XFS.  I think ext4
> would dramatically benefit from this a well, as would ext2 (although I
> think all that DAX work in ext2 is a horrible idea to start with).

It's been on my todo list.  The only reason why I haven't done it yet
is because I knew you were working on a solution, and I didn't want to
do things one way for buffered I/O, and a different way for Direct
I/O, and disentangling the DIO code and the different assumptions of
how different file systems interact with the DIO code is a *mess*.

It may have gotten better more recently, but a few years ago I took a
look at it and backed slowly away.....

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
