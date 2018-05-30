Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E67D66B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 19:01:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y26-v6so1973835pfn.14
        for <linux-mm@kvack.org>; Wed, 30 May 2018 16:01:32 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id o1-v6si23819587pga.261.2018.05.30.16.01.27
        for <linux-mm@kvack.org>;
        Wed, 30 May 2018 16:01:28 -0700 (PDT)
Date: Thu, 31 May 2018 09:01:20 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 02/13] mm: give the 'ret' variable a better name
 __do_page_cache_readahead
Message-ID: <20180530230120.GZ10363@dastard>
References: <20180530095813.31245-1-hch@lst.de>
 <20180530095813.31245-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530095813.31245-3-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:58:02AM +0200, Christoph Hellwig wrote:
> It counts the number of pages acted on, so name it nr_pages to make that
> obvious.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

*nod*

Reviewed-by: Dave Chinner <dchinner@redhat.com>

-- 
Dave Chinner
david@fromorbit.com
