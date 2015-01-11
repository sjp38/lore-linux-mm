Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 532F66B006C
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 13:39:28 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i17so15578651qcy.4
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 10:39:28 -0800 (PST)
Received: from mail-qa0-x232.google.com (mail-qa0-x232.google.com. [2607:f8b0:400d:c00::232])
        by mx.google.com with ESMTPS id s18si19892194qam.4.2015.01.11.10.39.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 10:39:27 -0800 (PST)
Received: by mail-qa0-f50.google.com with SMTP id k15so2895101qaq.9
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 10:39:27 -0800 (PST)
Date: Sun, 11 Jan 2015 13:39:24 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 12/12] fs: remove default_backing_dev_info
Message-ID: <20150111183924.GQ25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-13-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420739133-27514-13-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Thu, Jan 08, 2015 at 06:45:33PM +0100, Christoph Hellwig wrote:
> Now that default_backing_dev_info is not used for writeback purposes we can
> git rid of it easily:
> 
>  - instead of using it's name for tracing unregistered bdi we just use
>    "unknown"
>  - btrfs and ceph can just assign the default read ahead window themselves
>    like several other filesystems already do.
>  - we can assign noop_backing_dev_info as the default one in alloc_super.
>    All filesystems already either assigned their own or
>    noop_backing_dev_info.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
