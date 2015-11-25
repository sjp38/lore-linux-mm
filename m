Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 515776B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:47:53 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so51008930pac.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 00:47:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id xu3si32732095pab.194.2015.11.25.00.47.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 00:47:52 -0800 (PST)
Date: Wed, 25 Nov 2015 00:47:44 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Fix a bdi reregistration race, v2
Message-ID: <20151125084744.GA16429@infradead.org>
References: <564F9AFF.3050605@sandisk.com>
 <20151124231331.GA25591@infradead.org>
 <5654F169.6070000@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5654F169.6070000@sandisk.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Christoph Hellwig <hch@infradead.org>, James Bottomley <jbottomley@parallels.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, Aaro Koskinen <aaro.koskinen@iki.fi>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, linux-mm@kvack.org

Hi Bart,

On Tue, Nov 24, 2015 at 03:23:21PM -0800, Bart Van Assche wrote:
> So if a driver stops using a (major, minor) number pair and the same device
> number is reused before the bdi device has been released the warning
> mentioned in the patch description at the start of this thread is triggered.
> This patch fixes that race by removing the bdi device from sysfs during the
> __scsi_remove_device() call instead of when the bdi device is released.

that's why I suggested only releasing the minor number (or rather dev_t)
once we release the BDI, similar to what MD and DM do.

But what I really wanted to ask for is what your reproducer looks like.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
