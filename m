Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4C90B6B0032
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 12:05:51 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id x3so15311599qcv.1
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 09:05:51 -0800 (PST)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id w103si19614652qgd.53.2015.01.11.09.05.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 09:05:50 -0800 (PST)
Received: by mail-qg0-f47.google.com with SMTP id q108so15042197qgd.6
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 09:05:49 -0800 (PST)
Date: Sun, 11 Jan 2015 12:05:46 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 02/12] fs: kill BDI_CAP_SWAP_BACKED
Message-ID: <20150111170546.GI25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420739133-27514-3-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Thu, Jan 08, 2015 at 06:45:23PM +0100, Christoph Hellwig wrote:
> This bdi flag isn't too useful - we can determine that a vma is backed by
> either swap or shmem trivially in the caller.
> 
> This also allows removing the backing_dev_info instaces for swap and shmem
> in favor of noop_backing_dev_info.
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
