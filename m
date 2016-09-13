Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 22CFB6B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:44:09 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so392821560pad.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 23:44:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id tq7si25988783pab.0.2016.09.12.23.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 23:44:06 -0700 (PDT)
Date: Mon, 12 Sep 2016 23:44:05 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 1/2] mm, mincore2(): retrieve dax and tlb-size
 attributes of an address range
Message-ID: <20160913064405.GA21069@infradead.org>
References: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@ml01.01.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Sun, Sep 11, 2016 at 10:31:35AM -0700, Dan Williams wrote:
> As evidenced by this bug report [1], userspace libraries are interested
> in whether a mapping is DAX mapped, i.e. no intervening page cache.
> Rather than using the ambiguous VM_MIXEDMAP flag in smaps, provide an
> explicit "is dax" indication as a new flag in the page vector populated
> by mincore.

And how exactly does an implementation detail like DAX matter for an
application?  The only thing that might matter is the atomicy boundary,
but mincore is not the right interface for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
