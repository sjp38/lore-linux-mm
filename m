Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE8C46B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 14:54:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 190so125630940pfv.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 11:54:05 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c189si38022519pfc.233.2016.10.03.11.54.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 11:54:04 -0700 (PDT)
Date: Mon, 3 Oct 2016 12:54:03 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v4 00/12] re-enable DAX PMD support
Message-ID: <20161003185403.GD2044@linux.intel.com>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <20160929234345.GG27872@dastard>
 <20160930030343.GA12464@linux.intel.com>
 <20160930040055.GE9309@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160930040055.GE9309@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-xfs@vger.kernel.org

On Thu, Sep 29, 2016 at 09:00:55PM -0700, Darrick J. Wong wrote:
> On Thu, Sep 29, 2016 at 09:03:43PM -0600, Ross Zwisler wrote:
> > On Fri, Sep 30, 2016 at 09:43:45AM +1000, Dave Chinner wrote:
> > > Finally: none of the patches in your tree have reviewed-by tags.
> > > That says to me that none of this code has been reviewed yet.
> > > Reviewed-by tags are non-negotiable requirement for anything going
> > > through my trees. I don't have time right now to review this code,
> > > so you're going to need to chase up other reviewers before merging.
> > > 
> > > And, really, this is getting very late in the cycle to be merging
> > > new code - we're less than one working day away from the merge
> > > window opening and we've missed the last linux-next build. I'd
> > > suggest that we'd might be best served by slipping this to the PMD
> > > support code to the next cycle when there's no time pressure for
> > > review and we can get a decent linux-next soak on the code.
> > 
> > I absolutely support your policy of only sending code to Linux that has passed
> > peer review.
> > 
> > However, I do feel compelled to point out that this is not new code.  I didn't
> > just spring it on everyone in the hours before the v4.8 merge window.  I
> > posted the first version of this patch set on August 15th, *seven weeks ago*:
> > 
> > https://lkml.org/lkml/2016/8/15/613
> > 
> > This was the day after v4.7-rc2 was released.
> > 
> > Since then I have responded promptly to the little review feedback
> > that I've received.  I've also reviewed and tested other DAX changes,
> > like the struct iomap changes from Christoph.  Those changes were
> > first posted to the mailing list on September 9th, four weeks after
> > mine.  Nevertheless, I was happy to rebase my changes on top of his,
> > which meant a full rewrite of the DAX PMD fault handler so it would be
> > based on struct iomap.  His changes are going to be merged for v4.9,
> > and mine are not.
> 
> I'm not knocking the iomap migration, but it did cause a fair amount of
> churn in the XFS reflink patchset -- and that's for a filesystem that
> already /had/ iomap implemented.  It'd be neat to have all(?) the DAX
> filesystems (ext[24], XFS) move over to iomap so that you wouldn't have
> to support multiple ways of talking to FSes.  AFAICT ext4 hasn't gotten
> iomap, which complicates things.  But that's my opinion, maybe you're
> fine with supporting iomap and not-iomap.

I agree that we want to move everything over to be iomap based.   I think
Christoph is already working on moving ext4 over, but as of this set PMD
support explicitly depends on the iomap interface, and I'm itching to remove
the struct buffer_head + get_block_t PTE path and I/O path as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
