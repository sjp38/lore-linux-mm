Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2471A6B038C
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 19:54:25 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e129so42295165pfh.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 16:54:25 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id d17si1011612pgg.15.2017.03.06.16.54.23
        for <linux-mm@kvack.org>;
        Mon, 06 Mar 2017 16:54:24 -0800 (PST)
Date: Tue, 7 Mar 2017 11:54:20 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] xfs: remove kmem_zalloc_greedy
Message-ID: <20170307005420.GO17542@dastard>
References: <20170306184109.GC5280@birch.djwong.org>
 <20170307000754.GA9959@lst.de>
 <20170307001327.GC5281@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307001327.GC5281@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, Brian Foster <bfoster@redhat.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Mon, Mar 06, 2017 at 04:13:28PM -0800, Darrick J. Wong wrote:
> On Tue, Mar 07, 2017 at 01:07:54AM +0100, Christoph Hellwig wrote:
> > I like killing it, but shouldn't we just try a normal kmem_zalloc?
> > At least for the fallback it's the right thing, and even for an
> > order 2 allocation it seems like a useful first try.
> 
> I'm confused -- kmem_zalloc_large tries kmem_zalloc with KM_MAYFAIL and
> only falls back to __vmalloc if it doesn't get anything.

Yup, that's right.

> Or maybe I've misunderstood, and you're asking if we should try
> kmem_zalloc(4 pages), then kmem_zalloc(1 page), and only then switch to
> the __vmalloc calls?

Just call kmem_zalloc_large() for 4 pages without a fallback on
failure - that's exactly how we handle allocations for things like
the 64k xattr buffers....

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
