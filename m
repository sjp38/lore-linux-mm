Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 186706B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 10:29:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so15882562wme.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 07:29:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si32227011wmr.111.2016.05.10.07.29.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 07:29:41 -0700 (PDT)
Date: Tue, 10 May 2016 16:29:36 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 5/5] dax: fix a comment in dax_zero_page_range and
 dax_truncate_page
Message-ID: <20160510142936.GO11897@quack2.suse.cz>
References: <1462571591-3361-1-git-send-email-vishal.l.verma@intel.com>
 <1462571591-3361-6-git-send-email-vishal.l.verma@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462571591-3361-6-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <boaz@plexistor.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri 06-05-16 15:53:11, Vishal Verma wrote:
> The distinction between PAGE_SIZE and PAGE_CACHE_SIZE was removed in
> 
> 09cbfea mm, fs: get rid of PAGE_CACHE_* and page_cache_{get,release}
> macros
> 
> The comments for the above functions described a distinction between
> those, that is now redundant, so remove those paragraphs
> 
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>

Looks good. You can add:

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
