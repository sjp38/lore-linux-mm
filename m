Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id C99F76B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:18:26 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id f185so58468038vkb.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 08:18:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a198si12387194qkb.68.2016.04.15.08.18.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 08:18:25 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v2 4/5] dax: use sb_issue_zerout instead of calling dax_clear_sectors
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-5-git-send-email-vishal.l.verma@intel.com>
Date: Fri, 15 Apr 2016 11:18:22 -0400
In-Reply-To: <1459303190-20072-5-git-send-email-vishal.l.verma@intel.com>
	(Vishal Verma's message of "Tue, 29 Mar 2016 19:59:49 -0600")
Message-ID: <x49y48e6gu9.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@ml01.01.org, Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-block@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

Vishal Verma <vishal.l.verma@intel.com> writes:

> From: Matthew Wilcox <matthew.r.wilcox@intel.com>
>
> dax_clear_sectors() cannot handle poisoned blocks.  These must be
> zeroed using the BIO interface instead.  Convert ext2 and XFS to use
> only sb_issue_zerout().
>
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> [vishal: Also remove the dax_clear_sectors function entirely]
> Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>

Reviewed-by: Jeff Moyer <jmoyer@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
