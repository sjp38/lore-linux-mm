Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 405396B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:14:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 7so64272585pfa.2
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:14:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id h3si1454503pfg.132.2016.09.30.02.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Sep 2016 02:14:19 -0700 (PDT)
Date: Fri, 30 Sep 2016 02:14:18 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/20 v3] dax: Clear dirty bits after flushing caches
Message-ID: <20160930091418.GC24352@infradead.org>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:04PM +0200, Jan Kara wrote:
> Hello,
> 
> this is a third revision of my patches to clear dirty bits from radix tree of
> DAX inodes when caches for corresponding pfns have been flushed. This patch set
> is significantly larger than the previous version because I'm changing how
> ->fault, ->page_mkwrite, and ->pfn_mkwrite handlers may choose to handle the
> fault

Btw, is there ny good reason to keep ->fault, ->pmd_fault, page->mkwrite
and pfn_mkwrite separate these days?  All of them now take a struct
vm_fault, and the differences aren't exactly obvious for callers and
users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
