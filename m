Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 75E8A6B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 19:47:07 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q16-v6so12214920pls.15
        for <linux-mm@kvack.org>; Wed, 30 May 2018 16:47:07 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id i88-v6si8516183pfa.219.2018.05.30.16.47.05
        for <linux-mm@kvack.org>;
        Wed, 30 May 2018 16:47:06 -0700 (PDT)
Date: Thu, 31 May 2018 09:47:03 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 13/13] xfs: use iomap for blocksize == PAGE_SIZE readpage
 and readpages
Message-ID: <20180530234703.GK10363@dastard>
References: <20180530095813.31245-1-hch@lst.de>
 <20180530095813.31245-14-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530095813.31245-14-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:58:13AM +0200, Christoph Hellwig wrote:
> For file systems with a block size that equals the page size we never do
> partial reads, so we can use the buffer_head-less iomap versions of
> readpage and readpages without conflicting with the buffer_head structures
> create later in write_begin.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

Looks fine.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
-- 
Dave Chinner
david@fromorbit.com
