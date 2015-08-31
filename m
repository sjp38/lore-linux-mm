Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9206B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 15:34:52 -0400 (EDT)
Received: by wicjd9 with SMTP id jd9so10332607wic.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 12:34:51 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h6si324959wiv.105.2015.08.31.12.34.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 12:34:50 -0700 (PDT)
Date: Mon, 31 Aug 2015 21:34:49 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150831193449.GA27444@lst.de>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com> <20150831190619.GA27141@lst.de> <20150831192640.GA15717@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150831192640.GA15717@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On Mon, Aug 31, 2015 at 01:26:40PM -0600, Ross Zwisler wrote:
> > Should this be abstracted by adding a ->msync method?  Maybe not
> > worth to do for now, but it might be worth to keep that in mind.
> 
> Where would we add the ->msync method?  Do you mean to the PMEM API, or
> somewhere else?

vm_operations_struct would be the most logical choice, with filesystems
having a dax-specific instance of that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
