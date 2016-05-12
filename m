Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 011FF6B007E
	for <linux-mm@kvack.org>; Thu, 12 May 2016 04:41:42 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so20051175lfq.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 01:41:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 71si44108187wmr.122.2016.05.12.01.41.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 May 2016 01:41:40 -0700 (PDT)
Date: Thu, 12 May 2016 10:41:38 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 4/6] dax: export a low-level __dax_zero_page_range
 helper
Message-ID: <20160512084138.GC10306@quack2.suse.cz>
References: <1463000932-31680-1-git-send-email-vishal.l.verma@intel.com>
 <1463000932-31680-5-git-send-email-vishal.l.verma@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1463000932-31680-5-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@lists.01.org, Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <boaz@plexistor.com>

On Wed 11-05-16 15:08:50, Vishal Verma wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> This allows XFS to perform zeroing using the iomap infrastructure and
> avoid buffer heads.
> 
> [vishal: fix conflicts with dax-error-handling]
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

BTW: You are supposed to add your Signed-off-by when forwarding patches
like this...

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
