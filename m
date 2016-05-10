Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 88CA06B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 10:15:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so15553924wme.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 07:15:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3si2900740wjx.3.2016.05.10.07.15.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 07:15:49 -0700 (PDT)
Date: Tue, 10 May 2016 16:15:44 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 1/5] dax: fallback from pmd to pte on error
Message-ID: <20160510141544.GL11897@quack2.suse.cz>
References: <1462571591-3361-1-git-send-email-vishal.l.verma@intel.com>
 <1462571591-3361-2-git-send-email-vishal.l.verma@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462571591-3361-2-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <boaz@plexistor.com>

On Fri 06-05-16 15:53:07, Vishal Verma wrote:
> From: Dan Williams <dan.j.williams@intel.com>
> 
> In preparation for consulting a badblocks list in pmem_direct_access(),
> teach dax_pmd_fault() to fallback rather than fail immediately upon
> encountering an error.  The thought being that reducing the span of the
> dax request may avoid the error region.
> 
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

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
