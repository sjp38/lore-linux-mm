Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA916B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 07:24:35 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so1505557qcy.31
        for <linux-mm@kvack.org>; Thu, 15 May 2014 04:24:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 33si2378023qgi.174.2014.05.15.04.24.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 May 2014 04:24:35 -0700 (PDT)
Date: Thu, 15 May 2014 04:24:33 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Sync only the requested range in msync
Message-ID: <20140515112433.GA21206@infradead.org>
References: <1395961361-21307-1-git-send-email-matthew.r.wilcox@intel.com>
 <20140423141115.GA31375@infradead.org>
 <20140512163948.0b365598e1e4d0b06dea3bc6@linux-foundation.org>
 <x49y4y54xgq.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49y4y54xgq.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com

On Tue, May 13, 2014 at 09:31:01AM -0400, Jeff Moyer wrote:
> FWIW, I think we should apply the patch.  Anyone using the API properly
> will not get the desired result, and it could have a negative impact on
> performance.  The man page is very explicit on what you should expect,
> here.  Anyone relying on undocumented behavior gets to keep both pieces
> when it breaks.  That said, I do understand your viewpoint, Andrew,
> especially since it's so hard to get people to sync their data at all,
> much less correctly.

Agreed, we never made filesystems write out all data in the file system
in fsync either just because ext3 behaved that way.

And unlike that case I can't even see a good way to get msync wrong -
you call it on the mapped region, so expecting it to write out data
that isn't mapped at all seems rather odd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
