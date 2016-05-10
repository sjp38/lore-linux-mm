Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF53A6B0253
	for <linux-mm@kvack.org>; Tue, 10 May 2016 10:16:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so15700908wme.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 07:16:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gn6si2872129wjb.125.2016.05.10.07.16.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 07:16:42 -0700 (PDT)
Date: Tue, 10 May 2016 16:16:41 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 3/5] dax: use sb_issue_zerout instead of calling
 dax_clear_sectors
Message-ID: <20160510141641.GM11897@quack2.suse.cz>
References: <1462571591-3361-1-git-send-email-vishal.l.verma@intel.com>
 <1462571591-3361-4-git-send-email-vishal.l.verma@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462571591-3361-4-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@lists.01.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <boaz@plexistor.com>

On Fri 06-05-16 15:53:09, Vishal Verma wrote:
> From: Matthew Wilcox <matthew.r.wilcox@intel.com>
> 
> dax_clear_sectors() cannot handle poisoned blocks.  These must be
> zeroed using the BIO interface instead.  Convert ext2 and XFS to use
> only sb_issue_zerout().
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> [vishal: Also remove the dax_clear_sectors function entirely]
> Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>

The patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
