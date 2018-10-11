Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 972026B0006
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:44:00 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id m3-v6so6297412plt.9
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 06:44:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y9-v6si3032538plk.407.2018.10.11.06.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Oct 2018 06:43:59 -0700 (PDT)
Date: Thu, 11 Oct 2018 06:43:56 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 04/25] vfs: strengthen checking of file range inputs to
 generic_remap_checks
Message-ID: <20181011134356.GD23424@infradead.org>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923116686.5546.8711942394464060950.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153923116686.5546.8711942394464060950.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Wed, Oct 10, 2018 at 09:12:46PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> File range remapping, if allowed to run past the destination file's EOF,
> is an optimization on a regular file write.  Regular file writes that
> extend the file length are subject to various constraints which are not
> checked by range cloning.
> 
> This is a correctness problem because we're never allowed to touch
> ranges that the page cache can't support (s_maxbytes); we're not
> supposed to deal with large offsets (MAX_NON_LFS) if O_LARGEFILE isn't
> set; and we must obey resource limits (RLIMIT_FSIZE).
> 
> Therefore, add these checks to the new generic_remap_checks function so
> that we curtail unexpected behavior.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
