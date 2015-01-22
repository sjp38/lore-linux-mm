Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 44BAD6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:32:46 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id g10so1379825pdj.0
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 13:32:45 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id 12si9328463pda.13.2015.01.22.13.32.43
        for <linux-mm@kvack.org>;
        Thu, 22 Jan 2015 13:32:45 -0800 (PST)
Date: Fri, 23 Jan 2015 08:32:41 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 4/6] xfs: take i_mmap_lock on extent manipulation
 operations
Message-ID: <20150122213241.GB24722@dastard>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
 <1420669543-8093-5-git-send-email-david@fromorbit.com>
 <20150122132307.GB25345@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150122132307.GB25345@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 22, 2015 at 08:23:08AM -0500, Brian Foster wrote:
> On Thu, Jan 08, 2015 at 09:25:41AM +1100, Dave Chinner wrote:
> > diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
> > index 8be5bb5..f491860 100644
> > --- a/fs/xfs/xfs_iops.c
> > +++ b/fs/xfs/xfs_iops.c
> > @@ -768,7 +768,7 @@ xfs_setattr_size(
> >  	if (error)
> >  		return error;
> >  
> > -	ASSERT(xfs_isilocked(ip, XFS_IOLOCK_EXCL));
> > +	ASSERT(xfs_isilocked(ip, XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL));
> 
> Only debug code of course, but xfs_isilocked() doesn't appear to support
> what is intended by this call (e.g., verification of multiple locks).

Ah, right. Didn't think that one though properly. I'll fix it up.

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
