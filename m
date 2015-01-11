Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 423F66B0032
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 12:00:06 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id j5so15025294qga.7
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 09:00:06 -0800 (PST)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com. [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id r6si19624125qac.28.2015.01.11.09.00.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 09:00:05 -0800 (PST)
Received: by mail-qc0-f176.google.com with SMTP id i17so15489807qcy.7
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 09:00:04 -0800 (PST)
Date: Sun, 11 Jan 2015 12:00:00 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 01/12] fs: deduplicate noop_backing_dev_info
Message-ID: <20150111170000.GH25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-2-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420739133-27514-2-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Thu, Jan 08, 2015 at 06:45:22PM +0100, Christoph Hellwig wrote:
> hugetlbfs, kernfs and dlmfs can simply use noop_backing_dev_info instead
> of creating a local duplicate.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

For kernfs bits,

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
