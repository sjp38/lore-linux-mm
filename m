Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3C696B0266
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:37:41 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f17-v6so20427544plr.1
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:37:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n1-v6si16931808pld.205.2018.10.17.01.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 01:37:40 -0700 (PDT)
Date: Wed, 17 Oct 2018 01:37:38 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 24/26] xfs: fix pagecache truncation prior to reflink
Message-ID: <20181017083738.GH16896@infradead.org>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
 <153966004854.3607.15187709452762502392.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153966004854.3607.15187709452762502392.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 08:20:48PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Prior to remapping blocks, it is necessary to remove pages from the
> destination file's page cache.  Unfortunately, the truncation is not
> aggressive enough -- if page size > block size, we'll end up zeroing
> subpage blocks instead of removing them.  So, round the start offset
> down and the end offset up to page boundaries.  We already wrote all
> the dirty data so the larger range shouldn't be a problem.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> Reviewed-by: Dave Chinner <dchinner@redhat.com>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
