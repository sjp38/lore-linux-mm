Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A64BA6B0388
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 00:00:56 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l37so71452507wrc.7
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 21:00:56 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id g14si29128626wrg.275.2017.03.06.21.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 21:00:55 -0800 (PST)
Date: Tue, 7 Mar 2017 06:00:54 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] xfs: remove kmem_zalloc_greedy
Message-ID: <20170307050054.GB14000@lst.de>
References: <20170306184109.GC5280@birch.djwong.org> <20170307000754.GA9959@lst.de> <20170307001327.GC5281@birch.djwong.org> <20170307005420.GO17542@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307005420.GO17542@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Christoph Hellwig <hch@lst.de>, Brian Foster <bfoster@redhat.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Tue, Mar 07, 2017 at 11:54:20AM +1100, Dave Chinner wrote:
> > Or maybe I've misunderstood, and you're asking if we should try
> > kmem_zalloc(4 pages), then kmem_zalloc(1 page), and only then switch to
> > the __vmalloc calls?
> 
> Just call kmem_zalloc_large() for 4 pages without a fallback on
> failure - that's exactly how we handle allocations for things like
> the 64k xattr buffers....

Yeah, that sounds fine.  I didn't remember that we actually tried
kmalloc before vmalloc for kmem_zalloc_large.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
