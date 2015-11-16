Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id F0A0E6B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 09:41:34 -0500 (EST)
Received: by wmec201 with SMTP id c201so179903633wme.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 06:41:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m139si32963365wmb.0.2015.11.16.06.41.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Nov 2015 06:41:33 -0800 (PST)
Date: Mon, 16 Nov 2015 15:41:30 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 00/11] DAX fsynx/msync support
Message-ID: <20151116144130.GD3443@quack.suse.cz>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri 13-11-15 17:06:39, Ross Zwisler wrote:
> This patch series adds support for fsync/msync to DAX.
> 
> Patches 1 through 7 add various utilities that the DAX code will eventually
> need, and the DAX code itself is added by patch 8.  Patches 9-11 update the
> three filesystems that currently support DAX, ext2, ext4 and XFS, to use
> the new DAX fsync/msync code.
> 
> These patches build on the recent DAX locking changes from Dave Chinner,
> Jan Kara and myself.  Dave's changes for XFS and my changes for ext2 have
> been merged in the v4.4 window, but Jan's are still unmerged.  You can grab
> them here:
> 
> http://www.spinics.net/lists/linux-ext4/msg49951.html

I had a quick look and the patches look sane to me. I'll try to give them
more detailed look later this week. When thinking about the general design
I was wondering: When we have this infrastructure to track data potentially
lingering in CPU caches, would not it be a performance win to use standard
cached stores in dax_io() and mark corresponding pages as dirty in page
cache the same way as this patch set does it for mmaped writes? I have no
idea how costly are non-temporal stores compared to cached ones and how
would this compare to the cost of dirty tracking so this may be just
completely bogus...

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
