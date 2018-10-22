Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5576B000D
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 22:17:28 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z8-v6so28377991pgp.20
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 19:17:28 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id y2-v6si30862182pfn.26.2018.10.21.19.17.26
        for <linux-mm@kvack.org>;
        Sun, 21 Oct 2018 19:17:27 -0700 (PDT)
Date: Mon, 22 Oct 2018 13:17:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 27/28] xfs: remove xfs_reflink_remap_range
Message-ID: <20181022021724.GU6311@dastard>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
 <154013869100.29026.7543087084546497731.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154013869100.29026.7543087084546497731.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Sun, Oct 21, 2018 at 09:18:11AM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Since xfs_file_remap_range is a thin wrapper, move the contents of
> xfs_reflink_remap_range into the shell.  This cuts down on the vfs
> calls being made from internal xfs code.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Sensible enough.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
-- 
Dave Chinner
david@fromorbit.com
