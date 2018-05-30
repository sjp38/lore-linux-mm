Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 304EB6B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 05:52:53 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y16-v6so14702482wrp.19
        for <linux-mm@kvack.org>; Wed, 30 May 2018 02:52:53 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b6-v6si10045794wrm.331.2018.05.30.02.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 02:52:52 -0700 (PDT)
Date: Wed, 30 May 2018 11:59:11 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [Cluster-devel] [PATCH 11/34] iomap: move IOMAP_F_BOUNDARY to
	gfs2
Message-ID: <20180530095911.GB31068@lst.de>
References: <20180523144357.18985-1-hch@lst.de> <20180523144357.18985-12-hch@lst.de> <20180530055033.GZ30110@magnolia> <bc621d7c-f1a6-14c2-663f-57ded16811fa@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bc621d7c-f1a6-14c2-663f-57ded16811fa@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com, linux-mm@kvack.org

On Wed, May 30, 2018 at 10:30:32AM +0100, Steven Whitehouse wrote:
> I may have missed the context here, but I thought that the boundary was a 
> generic thing meaning "there will have to be a metadata read before more 
> blocks can be mapped" so I'm not sure why that would now be GFS2 specific?

It was always a hack.  But with iomap it doesn't make any sensee to start
with, all metadata I/O happens in iomap_begin, so there is no point in
marking an iomap with flags like this for the actual iomap interface.
