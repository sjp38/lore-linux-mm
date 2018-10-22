Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0BF6B0010
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 22:18:11 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 127-v6so7263443pgb.7
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 19:18:11 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id 30-v6si33273317pla.282.2018.10.21.19.18.09
        for <linux-mm@kvack.org>;
        Sun, 21 Oct 2018 19:18:10 -0700 (PDT)
Date: Mon, 22 Oct 2018 13:18:07 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 28/28] xfs: remove [cm]time update from reflink calls
Message-ID: <20181022021807.GV6311@dastard>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
 <154013869780.29026.674362788764806472.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154013869780.29026.674362788764806472.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Sun, Oct 21, 2018 at 09:18:17AM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Now that the vfs remap helper dirties the inode [cm]time for us, xfs no
> longer needs to do that on its own.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

looks good.

Reviewed-by: Dave Chinner <dchinner@redhat.com>
-- 
Dave Chinner
david@fromorbit.com
