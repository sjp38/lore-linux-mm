Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71A786B0389
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 19:13:38 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 187so67075512pgb.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 16:13:38 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w1si20549492pfb.70.2017.03.06.16.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 16:13:37 -0800 (PST)
Date: Mon, 6 Mar 2017 16:13:28 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH] xfs: remove kmem_zalloc_greedy
Message-ID: <20170307001327.GC5281@birch.djwong.org>
References: <20170306184109.GC5280@birch.djwong.org>
 <20170307000754.GA9959@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307000754.GA9959@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Brian Foster <bfoster@redhat.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>

On Tue, Mar 07, 2017 at 01:07:54AM +0100, Christoph Hellwig wrote:
> I like killing it, but shouldn't we just try a normal kmem_zalloc?
> At least for the fallback it's the right thing, and even for an
> order 2 allocation it seems like a useful first try.

I'm confused -- kmem_zalloc_large tries kmem_zalloc with KM_MAYFAIL and
only falls back to __vmalloc if it doesn't get anything.

Or maybe I've misunderstood, and you're asking if we should try
kmem_zalloc(4 pages), then kmem_zalloc(1 page), and only then switch to
the __vmalloc calls?

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
