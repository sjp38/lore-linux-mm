Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id CD7346B0253
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 15:51:17 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id xg9so43714816igb.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 12:51:17 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id s74si15259018ios.103.2016.02.11.12.51.16
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 12:51:17 -0800 (PST)
Date: Fri, 12 Feb 2016 07:50:49 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 0/2] DAX bdev fixes - move flushing calls to FS
Message-ID: <20160211205049.GJ19486@dastard>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
 <20160211124304.GI21760@quack.suse.cz>
 <20160211194922.GA5260@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160211194922.GA5260@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Thu, Feb 11, 2016 at 12:49:22PM -0700, Ross Zwisler wrote:
> I think the plan of unsetting S_DAX on bdev->bd_inode when we mount will save
> us from this, as long as we do it super early in the mount process.

I think that S_DAX should not be set on the block device by default
in the first place. If we've been surprised by unexpected behaviour,
then I'm sure there are going to be other surprises waiting for us.
DAX default policy should be opt-in, not opt-out.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
