Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 07D9F6B0032
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 12:40:18 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id i50so15084049qgf.11
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 09:40:17 -0800 (PST)
Received: from mail-qc0-x22c.google.com (mail-qc0-x22c.google.com. [2607:f8b0:400d:c01::22c])
        by mx.google.com with ESMTPS id 5si13648273qcl.7.2015.01.11.09.40.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 09:40:17 -0800 (PST)
Received: by mail-qc0-f172.google.com with SMTP id m20so15407354qcx.3
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 09:40:16 -0800 (PST)
Date: Sun, 11 Jan 2015 12:40:13 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 05/12] block_dev: get bdev inode bdi directly from the
 block device
Message-ID: <20150111174013.GL25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-6-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420739133-27514-6-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Thu, Jan 08, 2015 at 06:45:26PM +0100, Christoph Hellwig wrote:
> Directly grab the backing_dev_info from the request_queue instead of
> detouring through the address_space.
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
