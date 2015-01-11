Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 637B26B0032
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 12:24:31 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id p6so15416367qcv.9
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 09:24:31 -0800 (PST)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com. [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id l91si19607226qgl.90.2015.01.11.09.24.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 09:24:30 -0800 (PST)
Received: by mail-qc0-f176.google.com with SMTP id i17so15533388qcy.7
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 09:24:29 -0800 (PST)
Date: Sun, 11 Jan 2015 12:24:26 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 03/12] fs: introduce f_op->mmap_capabilities for nommu
 mmap support
Message-ID: <20150111172426.GJ25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-4-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420739133-27514-4-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Thu, Jan 08, 2015 at 06:45:24PM +0100, Christoph Hellwig wrote:
> Since "BDI: Provide backing device capability information [try #3]" the
> backing_dev_info structure also provides flags for the kind of mmap
> operation available in a nommu environment, which is entirely unrelated
> to it's original purpose.
> 
> Introduce a new nommu-only file operation to provide this information to
> the nommu mmap code instead.  Splitting this from the backing_dev_info
> structure allows to remove lots of backing_dev_info instance that aren't
> otherwise needed, and entirely gets rid of the concept of providing a
> backing_dev_info for a character device.  It also removes the need for
> the mtd_inodefs filesystem.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

FWIW,

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
