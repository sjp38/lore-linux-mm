Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 787286B0037
	for <linux-mm@kvack.org>; Mon, 19 May 2014 11:03:42 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so9299402qcy.31
        for <linux-mm@kvack.org>; Mon, 19 May 2014 08:03:42 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id d3si8809843qar.18.2014.05.19.08.03.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 May 2014 08:03:41 -0700 (PDT)
Date: Mon, 19 May 2014 08:03:39 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/8] mm: kill vm_operations_struct->remap_pages
Message-ID: <20140519150339.GA9300@infradead.org>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1399387052-31660-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399387052-31660-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

I think this should be split into two patches and go first in the
series:

 1) remove all instances but shmem and generic_file_vm_ops given that
    remap_file_pages already doesn't work on anything that has a backing
    store and all these are dead
 2) kill the method and make the syscall call generic_file_remap_pages
    directly as this is a core VM feature.

These two should go first because they make sense even if we can't
actually go with the emulation yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
