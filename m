Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07AEC6B0287
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 21:58:42 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hr10so16201285pac.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 18:58:41 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id k76si6359517pfb.178.2016.11.02.18.58.39
        for <linux-mm@kvack.org>;
        Wed, 02 Nov 2016 18:58:40 -0700 (PDT)
Date: Thu, 3 Nov 2016 12:58:26 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v9 00/16] re-enable DAX PMD support
Message-ID: <20161103015826.GI9920@dastard>
References: <1478030058-1422-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478030058-1422-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue, Nov 01, 2016 at 01:54:02PM -0600, Ross Zwisler wrote:
> DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> locking.  This series allows DAX PMDs to participate in the DAX radix tree
> based locking scheme so that they can be re-enabled.

I've seen patch 0/16 - where did you send the other 16? I need to
pick up the bug fix that is in this patch set...

> Previously we had talked about this series going through the XFS tree, but
> Jan has a patch set that will need to build on this series and it heavily
> modifies the MM code.  I think he would prefer that series to go through
> Andrew Morton's -MM tree, so it probably makes sense for this series to go
> through that same tree.

Seriously, I was 10 minutes away from pushing out the previous
version of this patchset as a stable topic branch, just like has
been discussed and several times over the past week.  Indeed, I
mentioned that I was planning on pushing out this topic branch today
not more than 4 hours ago, and you were on the cc list.

The -mm tree is not the place to merge patchsets with dependencies
like this because it's an unstable, rebasing tree. Hence it cannot
be shared and used as the base of common development between
multiple git trees like we have for the fs/ subsystem.

This needs to go out as a stable topic branch so that other
dependent work can reliably build on top of it for the next merge
window. e.g. the ext4 DAX iomap patch series that is likely to be
merged through the ext4 tree, so it needs a stable branch. There's
iomap direct IO patches for XFS pending, and they conflict with this
patchset. i.e. we need a stable git base to work from...

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
