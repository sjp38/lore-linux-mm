Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 064666B000A
	for <linux-mm@kvack.org>; Wed, 30 May 2018 19:09:09 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t17-v6so10795416ply.13
        for <linux-mm@kvack.org>; Wed, 30 May 2018 16:09:08 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id f9-v6si19147084pgn.334.2018.05.30.16.09.07
        for <linux-mm@kvack.org>;
        Wed, 30 May 2018 16:09:07 -0700 (PDT)
Date: Thu, 31 May 2018 09:09:05 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 08/13] iomap: use __bio_add_page in iomap_dio_zero
Message-ID: <20180530230905.GF10363@dastard>
References: <20180530095813.31245-1-hch@lst.de>
 <20180530095813.31245-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530095813.31245-9-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:58:08AM +0200, Christoph Hellwig wrote:
> We don't need any merging logic, and this also replaces a BUG_ON with a
> WARN_ON_ONCE inside __bio_add_page for the impossible overflow condition.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

looks good.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
-- 
Dave Chinner
david@fromorbit.com
