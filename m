Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 616496B025E
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 21:03:51 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id l13so17982403itl.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 18:03:51 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id g15si1398745itg.19.2016.09.29.18.03.23
        for <linux-mm@kvack.org>;
        Thu, 29 Sep 2016 18:03:24 -0700 (PDT)
Date: Fri, 30 Sep 2016 11:02:47 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC][PATCH] vfs,mm: fix a dead loop in
 truncate_inode_pages_range()
Message-ID: <20160930010247.GQ9806@dastard>
References: <1475151010-40166-1-git-send-email-fangwei1@huawei.com>
 <20160929134357.GA11463@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929134357.GA11463@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Wei Fang <fangwei1@huawei.com>, viro@ZenIV.linux.org.uk, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, stable@vger.kernel.org

On Thu, Sep 29, 2016 at 06:43:57AM -0700, Christoph Hellwig wrote:
> Can you please add a testcase for this to xfstests?

Seems like a copy of tests/xfs/071 (exercises read/write at the
highest page of the page cache) with an added ftruncate as a
generic tests would be a good start?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
