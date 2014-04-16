Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 923BF6B007B
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 02:31:32 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so10446736pdb.28
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 23:31:32 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id xy8si12107444pab.201.2014.04.15.23.31.30
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 23:31:31 -0700 (PDT)
Date: Wed, 16 Apr 2014 16:31:29 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 09/19] XFS: ensure xfs_file_*_read cannot deadlock in
 memory allocation.
Message-ID: <20140416063129.GI15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040336.10604.90380.stgit@notabene.brown>
 <20140416060459.GE15995@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140416060459.GE15995@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

On Wed, Apr 16, 2014 at 04:04:59PM +1000, Dave Chinner wrote:
> On Wed, Apr 16, 2014 at 02:03:36PM +1000, NeilBrown wrote:
> > xfs_file_*_read holds an inode lock while calling a generic 'read'
> > function.  These functions perform read-ahead and are quite likely to
> > allocate memory.
> 
> Yes, that's what reading data from disk requires.
> 
> > So set PF_FSTRANS to ensure they avoid __GFP_FS and so don't recurse
> > into a filesystem to free memory.
> 
> We already have that protection via the

Oops, stray paste. Ignore that comment.

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
