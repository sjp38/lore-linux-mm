Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62D1D6B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 19:46:42 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o23-v6so12128592pll.12
        for <linux-mm@kvack.org>; Wed, 30 May 2018 16:46:42 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id w1-v6si19911730ply.425.2018.05.30.16.46.38
        for <linux-mm@kvack.org>;
        Wed, 30 May 2018 16:46:39 -0700 (PDT)
Date: Thu, 31 May 2018 09:46:37 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 12/13] xfs: use iomap_bmap
Message-ID: <20180530234637.GJ10363@dastard>
References: <20180530095813.31245-1-hch@lst.de>
 <20180530095813.31245-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530095813.31245-13-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:58:12AM +0200, Christoph Hellwig wrote:
> Switch to the iomap based bmap implementation to get rid of one of the
> last users of xfs_get_blocks.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

Looks good.

Reviewed-by: Dave Chinner <dchinner@redhat.com>

-- 
Dave Chinner
david@fromorbit.com
