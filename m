Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 941206B007E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 06:45:52 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fe3so44214014pab.1
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 03:45:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ui8si8554617pab.38.2016.03.25.03.45.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Mar 2016 03:45:51 -0700 (PDT)
Date: Fri, 25 Mar 2016 03:45:49 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160325104549.GB10525@infradead.org>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
 <1458861450-17705-6-git-send-email-vishal.l.verma@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458861450-17705-6-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Mar 24, 2016 at 05:17:30PM -0600, Vishal Verma wrote:
> dax_do_io (called for read() or write() for a dax file system) may fail
> in the presence of bad blocks or media errors. Since we expect that a
> write should clear media errors on nvdimms, make dax_do_io fall back to
> the direct_IO path, which will send down a bio to the driver, which can
> then attempt to clear the error.

Leave the fallback on -EIO to the callers please.  They generally call
__blockdev_direct_IO anyway, so it should actually become simpler that
way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
