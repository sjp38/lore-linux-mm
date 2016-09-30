Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C83E6B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 23:03:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 2so127017610pfs.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 20:03:45 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id dd9si17558692pad.31.2016.09.29.20.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 20:03:44 -0700 (PDT)
Date: Thu, 29 Sep 2016 21:03:43 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v4 00/12] re-enable DAX PMD support
Message-ID: <20160930030343.GA12464@linux.intel.com>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <20160929234345.GG27872@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929234345.GG27872@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Fri, Sep 30, 2016 at 09:43:45AM +1000, Dave Chinner wrote:
> Finally: none of the patches in your tree have reviewed-by tags.
> That says to me that none of this code has been reviewed yet.
> Reviewed-by tags are non-negotiable requirement for anything going
> through my trees. I don't have time right now to review this code,
> so you're going to need to chase up other reviewers before merging.
> 
> And, really, this is getting very late in the cycle to be merging
> new code - we're less than one working day away from the merge
> window opening and we've missed the last linux-next build. I'd
> suggest that we'd might be best served by slipping this to the PMD
> support code to the next cycle when there's no time pressure for
> review and we can get a decent linux-next soak on the code.

I absolutely support your policy of only sending code to Linux that has passed
peer review.

However, I do feel compelled to point out that this is not new code.  I didn't
just spring it on everyone in the hours before the v4.8 merge window.  I
posted the first version of this patch set on August 15th, *seven weeks ago*:

https://lkml.org/lkml/2016/8/15/613

This was the day after v4.7-rc2 was released.

Since then I have responded promptly to the little review feedback that I've
received.  I've also reviewed and tested other DAX changes, like the struct
iomap changes from Christoph.  Those changes were first posted to the mailing
list on September 9th, four weeks after mine.  Nevertheless, I was happy to
rebase my changes on top of his, which meant a full rewrite of the DAX PMD
fault handler so it would be based on struct iomap.  His changes are going to
be merged for v4.9, and mine are not.

Please, help me understand what I can do to get my code reviewed.  Do I need
to more aggressively ping my patch series, asking people by name for reviews?
Do we need to rework our code flow to Linus so that the DAX changes go through
a filesystem tree like XFS or ext4, and ask the developers of that filesystem
to help with reviews?  Something else?

I'm honestly very frustrated by this because I've done my best to be open to
constructive criticism and I've tried to respond promptly to the feedback that
I've received.  In the end, though, a system where it's a requirement that all
upstreamed code be peer reviewed but in which I can't get any feedback is
essentially a system where I'm not allowed to contribute.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
