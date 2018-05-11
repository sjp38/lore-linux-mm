Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCC26B0659
	for <linux-mm@kvack.org>; Fri, 11 May 2018 02:21:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d4-v6so2955974wrn.15
        for <linux-mm@kvack.org>; Thu, 10 May 2018 23:21:43 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u48-v6si2202661wrb.109.2018.05.10.23.21.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 23:21:41 -0700 (PDT)
Date: Fri, 11 May 2018 08:25:27 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 10/33] iomap: add an iomap-based bmap implementation
Message-ID: <20180511062527.GE7962@lst.de>
References: <20180509074830.16196-1-hch@lst.de> <20180509074830.16196-11-hch@lst.de> <20180509164628.GV11261@magnolia> <20180510064250.GD11422@lst.de> <20180510150838.GE25312@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180510150838.GE25312@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Thu, May 10, 2018 at 08:08:38AM -0700, Darrick J. Wong wrote:
> > > > +	sector_t *bno = data;
> > > > +
> > > > +	if (iomap->type == IOMAP_MAPPED)
> > > > +		*bno = (iomap->addr + pos - iomap->offset) >> inode->i_blkbits;
> > > 
> > > Does this need to be careful w.r.t. overflow on systems where sector_t
> > > is a 32-bit unsigned long?
> > > 
> > > Also, ioctl_fibmap() typecasts the returned sector_t to an int, which
> > > also seems broken.  I agree the interface needs to die, but ioctls take
> > > a long time to deprecate.
> > 
> > Not much we can do about the interface.
> 
> Yes, the interface is fubar, but if file /foo maps to block 8589934720
> then do we return the truncated result 128?

Then we'll get a corrupt result.  What do you think we could do here
eithere in the old or new code?
