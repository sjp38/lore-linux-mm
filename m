Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 653936B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 15:06:22 -0400 (EDT)
Received: by wibq14 with SMTP id q14so9739118wib.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 12:06:22 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t10si28667649wje.2.2015.08.31.12.06.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 12:06:21 -0700 (PDT)
Date: Mon, 31 Aug 2015 21:06:19 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150831190619.GA27141@lst.de>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On Mon, Aug 31, 2015 at 12:59:44PM -0600, Ross Zwisler wrote:
> For DAX msync we just need to flush the given range using
> wb_cache_pmem(), which is now a public part of the PMEM API.
> 
> The inclusion of <linux/dax.h> in fs/dax.c was done to make checkpatch
> happy.  Previously it was complaining about a bunch of undeclared
> functions that could be made static.

Should this be abstracted by adding a ->msync method?  Maybe not
worth to do for now, but it might be worth to keep that in mind.

Otherwise this looks fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
