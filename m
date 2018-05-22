Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE0C6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 16:28:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w8-v6so5194422wrn.10
        for <linux-mm@kvack.org>; Tue, 22 May 2018 13:28:17 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d4-v6si10633798wrq.234.2018.05.22.13.28.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 13:28:15 -0700 (PDT)
Date: Tue, 22 May 2018 22:33:34 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: buffered I/O without buffer heads in xfs and iomap v2
Message-ID: <20180522203334.GA24978@lst.de>
References: <20180518164830.1552-1-hch@lst.de> <20180521204610.GC4507@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180521204610.GC4507@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon, May 21, 2018 at 01:46:10PM -0700, Darrick J. Wong wrote:
> On Fri, May 18, 2018 at 06:47:56PM +0200, Christoph Hellwig wrote:
> > Hi all,
> > 
> > this series adds support for buffered I/O without buffer heads to
> > the iomap and XFS code.
> > 
> > For now this series only contains support for block size == PAGE_SIZE,
> > with the 4k support split into a separate series.
> > 
> > 
> > A git tree is available at:
> > 
> >     git://git.infradead.org/users/hch/xfs.git xfs-iomap-read.2
> > 
> > Gitweb:
> > 
> >     http://git.infradead.org/users/hch/xfs.git/shortlog/refs/heads/xfs-iomap-read.2
> 
> Hmm, so I pulled this and ran my trivial stupid benchmark on for-next.
> It's a stupid VM with a 2G of RAM and a 12GB virtio-scsi disk backed by
> tmpfs:

The xfs-iomap-read.3 branch in the above repo should sort out these
issues.  Still waiting for some more feedback before reposting.
