Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5446B0292
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 08:45:44 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id s187so5669386ywf.1
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 05:45:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 206si722644ywb.55.2017.08.29.05.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 05:45:43 -0700 (PDT)
Date: Tue, 29 Aug 2017 05:45:36 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab
 cache
Message-ID: <20170829124536.GA26339@infradead.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org>
 <20170829081453.GA10196@infradead.org>
 <20170829123126.GB10621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829123126.GB10621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Tue, Aug 29, 2017 at 10:31:26PM +1000, Dave Chinner wrote:
> Probably should.  I've already been looking at killing the inline
> extents array to simplify the management of the extent list (much
> simpler to index by rbtree when we don't have direct/indirect
> structures), so killing the inline data would get rid of the other
> part of the union the inline data sits in.

That's exactly where I came form with my extent list work.  Although
the rbtree performance was horrible due to the memory overhead and
I've switched to a modified b+tree at the moment..

> OTOH, if we're going to have to dynamically allocate the memory for
> the extent/inline data for the data fork, it may just be easier to
> make the entire data fork a dynamic allocation (like the attr fork).

I though about this a bit, but it turned out that we basically
always need the data anyway, so I don't think it's going to buy
us much unless we shrink the inode enough so that they better fit
into a page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
