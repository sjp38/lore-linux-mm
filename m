Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B63D96B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 19:08:47 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x6-v6so55664pgp.9
        for <linux-mm@kvack.org>; Wed, 30 May 2018 16:08:47 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id e11-v6si28304516pgr.423.2018.05.30.16.08.45
        for <linux-mm@kvack.org>;
        Wed, 30 May 2018 16:08:46 -0700 (PDT)
Date: Thu, 31 May 2018 09:08:44 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 07/13] iomap: move IOMAP_F_BOUNDARY to gfs2
Message-ID: <20180530230844.GE10363@dastard>
References: <20180530095813.31245-1-hch@lst.de>
 <20180530095813.31245-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530095813.31245-8-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:58:07AM +0200, Christoph Hellwig wrote:
> Just define a range of fs specific flags and use that in gfs2 instead of
> exposing this internal flag flobally.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

Makes sense to have a private range for the flags - cleans this up
nicely.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
-- 
Dave Chinner
david@fromorbit.com
