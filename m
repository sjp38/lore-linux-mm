Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 161186B027D
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 13:51:05 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id bi5so1971416pad.0
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 10:51:05 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id i84si10833735pfi.299.2016.11.03.10.51.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 10:51:04 -0700 (PDT)
Date: Thu, 3 Nov 2016 11:51:02 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v9 00/16] re-enable DAX PMD support
Message-ID: <20161103175102.GA11784@linux.intel.com>
References: <1478030058-1422-1-git-send-email-ross.zwisler@linux.intel.com>
 <20161103015826.GI9920@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161103015826.GI9920@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Nov 03, 2016 at 12:58:26PM +1100, Dave Chinner wrote:
> On Tue, Nov 01, 2016 at 01:54:02PM -0600, Ross Zwisler wrote:
> > DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> > locking.  This series allows DAX PMDs to participate in the DAX radix tree
> > based locking scheme so that they can be re-enabled.
> 
> I've seen patch 0/16 - where did you send the other 16? I need to
> pick up the bug fix that is in this patch set...

I CC'd your "david@fromorbit.com" address on the entire set, as well as all
the usual lists (linux-xfs, linux-fsdevel, linux-nvdimm, etc).

They are also available via the libnvdimm patchwork:

https://patchwork.kernel.org/project/linux-nvdimm/list/

or via my tree:

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_pmd_v9

The only patch that is different between v8 and v9 is:
[PATCH v9 14/16] dax: add struct iomap based DAX PMD support

> > Previously we had talked about this series going through the XFS tree, but
> > Jan has a patch set that will need to build on this series and it heavily
> > modifies the MM code.  I think he would prefer that series to go through
> > Andrew Morton's -MM tree, so it probably makes sense for this series to go
> > through that same tree.
> 
> Seriously, I was 10 minutes away from pushing out the previous
> version of this patchset as a stable topic branch, just like has
> been discussed and several times over the past week.  Indeed, I
> mentioned that I was planning on pushing out this topic branch today
> not more than 4 hours ago, and you were on the cc list.

I'm confused - I sent v9 of this series out 2 days ago, on Tuesday?
I have seen multiple messages from you this week saying you were going to pick
this series up, but I saw them all after I had already sent this series out.

> The -mm tree is not the place to merge patchsets with dependencies
> like this because it's an unstable, rebasing tree. Hence it cannot
> be shared and used as the base of common development between
> multiple git trees like we have for the fs/ subsystem.
> 
> This needs to go out as a stable topic branch so that other
> dependent work can reliably build on top of it for the next merge
> window. e.g. the ext4 DAX iomap patch series that is likely to be
> merged through the ext4 tree, so it needs a stable branch. There's
> iomap direct IO patches for XFS pending, and they conflict with this
> patchset. i.e. we need a stable git base to work from...

Yea, my apologies.  Really this comes down to a lack of understanding on my
part about about which series should be merged via which maintainers, and how
stable topic branches can be shared.  I didn't realize that if you make a
stable branch that could be easily used by other trees, and that for example
Jan's MM or ext4 based patches could be merged by another maintainer but be
based on your topic branch.

Sorry for the confusion, I was just trying to figure out a way that Jan's
changes could also be merged.  Please do pick up v9 of my PMD set. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
