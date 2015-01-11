Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id E20DB6B0032
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 13:33:58 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id f51so15177698qge.8
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 10:33:58 -0800 (PST)
Received: from mail-qa0-x22d.google.com (mail-qa0-x22d.google.com. [2607:f8b0:400d:c00::22d])
        by mx.google.com with ESMTPS id p61si19766165qga.97.2015.01.11.10.33.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 10:33:57 -0800 (PST)
Received: by mail-qa0-f45.google.com with SMTP id f12so12987427qad.4
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 10:33:57 -0800 (PST)
Date: Sun, 11 Jan 2015 13:33:54 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 11/12] fs: don't reassign dirty inodes to
 default_backing_dev_info
Message-ID: <20150111183354.GP25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-12-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420739133-27514-12-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Thu, Jan 08, 2015 at 06:45:32PM +0100, Christoph Hellwig wrote:
> If we have dirty inodes we need to call the filesystem for it, even if the
> device has been removed and the filesystem will error out early.  The
> current code does that by reassining all dirty inodes to the default
> backing_dev_info when a bdi is unlinked, but that's pretty pointless given
> that the bdi must always outlive the super block.

It's also shifting writeback shutdown to destroy time from
unregistration time.  This is part of fixing the bdi lifetime issue,
right?  It hink It'd be worthwhile to mention that in the commit
message.

Other than that,

 Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
