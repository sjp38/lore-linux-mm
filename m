Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id A36BD6B033A
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 23:52:57 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id x4so1336096ybf.11
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 20:52:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h2si477768ywj.553.2017.12.05.20.52.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 20:52:56 -0800 (PST)
Date: Tue, 5 Dec 2017 20:52:54 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171206045254.GP26021@bombadil.infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-73-willy@infradead.org>
 <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
 <20171206031456.GE4094@dastard>
 <20171206044549.GO26021@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206044549.GO26021@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 05, 2017 at 08:45:49PM -0800, Matthew Wilcox wrote:
> The dquot code is just going to have to live with the fact that there's
> additional locking going on that it doesn't need.  I'm open to getting
> rid of the irqsafety, but we can't give up the spinlock protection
> without giving up the RCU/lockdep analysis and the ability to move nodes.
> I don't suppose the dquot code can 

Oops, thought I'd finished writing this paragraph.

I don't suppose the dquot code can be restructured to use the xa_lock to
protect, say, qi_dquots?  I suspect not, since you wouldn't know which
of the three xarray locks to use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
