Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF356B0069
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 18:12:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u84so229186773pfj.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 15:12:57 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b20si37490547pfk.263.2016.10.18.15.12.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 15:12:56 -0700 (PDT)
Date: Tue, 18 Oct 2016 16:12:54 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 20/20] dax: Clear dirty entry tags on cache flush
Message-ID: <20161018221254.GG7796@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-21-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-21-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:24PM +0200, Jan Kara wrote:
> Currently we never clear dirty tags in DAX mappings and thus address
> ranges to flush accumulate. Now that we have locking of radix tree
> entries, we have all the locking necessary to reliably clear the radix
> tree dirty tag when flushing caches for corresponding address range.
> Similarly to page_mkclean() we also have to write-protect pages to get a
> page fault when the page is next written to so that we can mark the
> entry dirty again.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Looks great. 

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
