Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 249676B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 07:33:55 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id y19so2867814wgg.4
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 04:33:54 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id km10si35414614wjc.32.2015.01.12.04.33.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 04:33:53 -0800 (PST)
Date: Mon, 12 Jan 2015 13:33:51 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 04/12] block_dev: only write bdev inode on close
Message-ID: <20150112123351.GA29325@lst.de>
References: <1420739133-27514-1-git-send-email-hch@lst.de> <1420739133-27514-5-git-send-email-hch@lst.de> <20150111173209.GK25319@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150111173209.GK25319@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

On Sun, Jan 11, 2015 at 12:32:09PM -0500, Tejun Heo wrote:
> Is this an optimization or something necessary for the following
> changes?  If latter, maybe it's a good idea to state why this is
> necessary in the description?  Otherwise,

It gets rid of a bdi reassignment, and thus makes life a lot simpler.
I'll update the commit message.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
