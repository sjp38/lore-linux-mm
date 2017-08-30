Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05AAB6B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 04:33:55 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id p77so3394940ywp.3
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:33:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t204si1211505ywt.288.2017.08.30.01.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 01:33:50 -0700 (PDT)
Date: Wed, 30 Aug 2017 01:33:44 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab
 cache
Message-ID: <20170830083344.GA30197@infradead.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org>
 <20170829081453.GA10196@infradead.org>
 <20170829123126.GB10621@dastard>
 <20170829124536.GA26339@infradead.org>
 <20170829215157.GC10621@dastard>
 <20170830071403.GA8904@infradead.org>
 <20170830080558.GK10621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170830080558.GK10621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Wed, Aug 30, 2017 at 06:05:58PM +1000, Dave Chinner wrote:
> Ok, that's sounds like it'll fit right in with what I've been
> prototyping for the extent code in xfs_bmap.c. I can make that work
> with a cursor-based lookup/inc/dec/ins/del API similar to the bmbt
> API. I've been looking to abstract the extent manipulations out into
> functions that modify both trees like this:
> 
> [note: just put template code in to get my thoughts straight, it's
> not working code]

FYI, I've got somewhat working changes in that area (still has bugs
but a few tests pass :)), what I'm doing is to make sure all of
the xfs_bmap_{add,del}_extent_* routines fully operate on xfs_bmbt_irec
structures that they acquire through the xfs_bmalloca structure or
from xfs_iext_get_extent and update using xfs_iext_update_extent.
A nice fallout from that is that we can change the prototypes for
xfs_bmbt_lookup_* and xfs_bmbt_update to take a xfs_bmbt_irec
as well instead of taking the individual arguments.  That should
help with your next step cleanups a bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
