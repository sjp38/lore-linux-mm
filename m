Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 78FE66B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 03:06:38 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id x12so37121753wgg.4
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 00:06:38 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id l3si21845699wic.38.2015.02.02.00.06.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 00:06:37 -0800 (PST)
Date: Mon, 2 Feb 2015 09:06:35 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: backing_dev_info cleanups & lifetime rule fixes V2
Message-ID: <20150202080635.GB9851@lst.de>
References: <1421228561-16857-1-git-send-email-hch@lst.de> <54BEC3C2.7080906@fb.com> <20150201063116.GP29656@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150201063116.GP29656@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@lst.de>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Sun, Feb 01, 2015 at 06:31:16AM +0000, Al Viro wrote:
> And at that point we finally can make sb_lock and super_blocks static in
> fs/super.c.  Do you want that in your tree, or would you rather have it
> done via vfs.git during the merge window after your tree goes in?  It's
> as trivial as this:
> 
> Make super_blocks and sb_lock static
> 
> The only user outside of fs/super.c is gone now
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

I'd say merge it through the block tree..

Acked-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
