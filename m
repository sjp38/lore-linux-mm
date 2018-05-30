Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3B06B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 19:10:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c4-v6so11614888pfg.22
        for <linux-mm@kvack.org>; Wed, 30 May 2018 16:10:15 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id n10-v6si27865888pgq.472.2018.05.30.16.10.13
        for <linux-mm@kvack.org>;
        Wed, 30 May 2018 16:10:14 -0700 (PDT)
Date: Thu, 31 May 2018 09:10:11 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 09/13] iomap: add a iomap_sector helper
Message-ID: <20180530231011.GG10363@dastard>
References: <20180530095813.31245-1-hch@lst.de>
 <20180530095813.31245-10-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530095813.31245-10-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:58:09AM +0200, Christoph Hellwig wrote:
> Factor the repeated calculation of the on-disk sector for a given logical
> block into a littler helper.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

looks good.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
-- 
Dave Chinner
david@fromorbit.com
