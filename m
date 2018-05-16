Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6086B0300
	for <linux-mm@kvack.org>; Wed, 16 May 2018 01:46:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q15-v6so1885382pff.17
        for <linux-mm@kvack.org>; Tue, 15 May 2018 22:46:17 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id k26-v6si1504483pgn.209.2018.05.15.22.46.15
        for <linux-mm@kvack.org>;
        Tue, 15 May 2018 22:46:15 -0700 (PDT)
Date: Wed, 16 May 2018 15:46:11 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 31/33] iomap: add support for sub-pagesize buffered I/O
 without buffer heads
Message-ID: <20180516054611.GK10363@dastard>
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-32-hch@lst.de>
 <eebcc4bf-f646-edc6-264b-124b3880f3cb@suse.de>
 <20180515072625.GA23384@lst.de>
 <8b36b6c2-03b0-ea66-9bea-df2695dd1dba@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b36b6c2-03b0-ea66-9bea-df2695dd1dba@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Tue, May 15, 2018 at 08:47:25AM -0500, Goldwyn Rodrigues wrote:
> On 05/15/2018 02:26 AM, Christoph Hellwig wrote:
> > On Mon, May 14, 2018 at 11:00:08AM -0500, Goldwyn Rodrigues wrote:
> >>> +	if (iop || i_blocksize(inode) == PAGE_SIZE)
> >>> +		return iop;
> >>
> >> Why is this an equal comparison operator? Shouldn't this be >= to
> >> include filesystem blocksize greater than PAGE_SIZE?
> > 
> > Which filesystems would that be that have a tested and working PAGE_SIZE
> > support using iomap?
> 
> Oh, I assumed iomap would work for filesystems with block size greater
> than PAGE_SIZE.

It will eventually, but first we've got to remove the iomap
infrastructure and filesystem dependencies on bufferheads....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
