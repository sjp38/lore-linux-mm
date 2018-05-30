Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E22D6B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 19:05:06 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e1-v6so12068800pld.23
        for <linux-mm@kvack.org>; Wed, 30 May 2018 16:05:06 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id w19-v6si34453022plp.538.2018.05.30.16.05.04
        for <linux-mm@kvack.org>;
        Wed, 30 May 2018 16:05:05 -0700 (PDT)
Date: Thu, 31 May 2018 09:05:02 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 05/13] iomap: inline data should be an iomap type, not a
 flag
Message-ID: <20180530230502.GC10363@dastard>
References: <20180530095813.31245-1-hch@lst.de>
 <20180530095813.31245-6-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530095813.31245-6-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:58:05AM +0200, Christoph Hellwig wrote:
> Inline data is fundamentally different from our normal mapped case in that
> it doesn't even have a block address.  So instead of having a flag for it
> it should be an entirely separate iomap range type.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

looks good.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
-- 
Dave Chinner
david@fromorbit.com
