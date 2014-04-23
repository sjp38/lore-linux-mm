Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id B02D26B0036
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 10:11:18 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id w7so956943qcr.25
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 07:11:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id d4si511058qar.41.2014.04.23.07.11.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Apr 2014 07:11:16 -0700 (PDT)
Date: Wed, 23 Apr 2014 07:11:15 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Sync only the requested range in msync
Message-ID: <20140423141115.GA31375@infradead.org>
References: <1395961361-21307-1-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1395961361-21307-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com

On Thu, Mar 27, 2014 at 07:02:41PM -0400, Matthew Wilcox wrote:
> [untested.  posted because it keeps coming up at lsfmm/collab]
> 
> msync() currently syncs more than POSIX requires or BSD or Solaris
> implement.  It is supposed to be equivalent to fdatasync(), not fsync(),
> and it is only supposed to sync the portion of the file that overlaps
> the range passed to msync.
> 
> If the VMA is non-linear, fall back to syncing the entire file, but we
> still optimise to only fdatasync() the entire file, not the full fsync().
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
