Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4E56B0032
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 13:20:29 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id v8so2895103qal.7
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 10:20:29 -0800 (PST)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com. [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id d9si19786476qag.47.2015.01.11.10.20.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 10:20:28 -0800 (PST)
Received: by mail-qc0-f180.google.com with SMTP id i8so15428099qcq.11
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 10:20:28 -0800 (PST)
Date: Sun, 11 Jan 2015 13:20:25 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 08/12] fs: remove mapping->backing_dev_info
Message-ID: <20150111182025.GO25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-9-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420739133-27514-9-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Thu, Jan 08, 2015 at 06:45:29PM +0100, Christoph Hellwig wrote:
> Now that we never use the backing_dev_info pointer in struct address_space
> we can simply remove it and save 4 to 8 bytes in every inode.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
