Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3BAFA6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:36:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 194so108223861pgd.7
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:36:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j15si859651pfj.118.2017.02.06.06.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:36:54 -0800 (PST)
Date: Mon, 6 Feb 2017 06:36:48 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: replace FAULT_FLAG_SIZE with parameter to huge_fault
Message-ID: <20170206143648.GA461@infradead.org>
References: <148615748258.43180.1690152053774975329.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148615748258.43180.1690152053774975329.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, dave.hansen@linux.intel.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, linux-ext4@vger.kernel.org, kirill.shutemov@linux.intel.com

On Fri, Feb 03, 2017 at 02:31:22PM -0700, Dave Jiang wrote:
> Since the introduction of FAULT_FLAG_SIZE to the vm_fault flag, it has
> been somewhat painful with getting the flags set and removed at the
> correct locations. More than one kernel oops was introduced due to
> difficulties of getting the placement correctly. Removing the flag
> values and introducing an input parameter to huge_fault that indicates
> the size of the page entry. This makes the code easier to trace and
> should avoid the issues we see with the fault flags where removal of the
> flag was necessary in the fallback paths.

Why is this not in struct vm_fault?  Also can be use this opportunity
to fold ->huge_fault into ->fault?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
