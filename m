Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8A26B0010
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:40:33 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b22-v6so7708200pfc.18
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 06:40:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y73-v6si29704175pfi.61.2018.10.11.06.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Oct 2018 06:40:32 -0700 (PDT)
Date: Thu, 11 Oct 2018 06:40:29 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 02/25] vfs: vfs_clone_file_prep_inodes should return
 EINVAL for a clone from beyond EOF
Message-ID: <20181011134029.GB23424@infradead.org>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923115041.5546.14464512857556875980.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153923115041.5546.14464512857556875980.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Wed, Oct 10, 2018 at 09:12:30PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> vfs_clone_file_prep_inodes cannot return 0 if it is asked to remap from
> a zero byte file because that's what btrfs does.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---

Maybe it would be a good time to switch btrfs to use
vfs_clone_file_prep_inodes so that we don't have any discrepancies?

Otherwise looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
