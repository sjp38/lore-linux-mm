Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id ADB7D6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:44:20 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id a11so607189qen.5
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 09:44:20 -0800 (PST)
Received: from a9-42.smtp-out.amazonses.com (a9-42.smtp-out.amazonses.com. [54.240.9.42])
        by mx.google.com with ESMTP id f1si19420563qar.164.2013.12.12.09.44.19
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 09:44:19 -0800 (PST)
Date: Thu, 12 Dec 2013 17:44:18 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 3/3] mm: slabs: reset page at free
In-Reply-To: <20131211224028.9D7AD2B7@viggo.jf.intel.com>
Message-ID: <00000142e7e8ba5d-bcdf8715-dd6a-411a-8c55-12a4668c6489-000000@email.amazonses.com>
References: <20131211224022.AA8CF0B9@viggo.jf.intel.com> <20131211224028.9D7AD2B7@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>

On Wed, 11 Dec 2013, Dave Hansen wrote:

> We now have slub's ->freelist usage impinging on page->mapping's
> storage space.  The buddy allocator wants ->mapping to be NULL
> when a page is handed back, so we have to make sure that it is
> cleared.
>
> Note that slab already doeds this, so just create a common helper
> and have all the slabs do it this way.  ->mapping is right next
> to ->flags, so it's virtually guaranteed to be in the L1 at this
> point, so this shouldn't cost very much to do in practice.

Maybe add a common page alloc and free function in mm/slab_common.c?

All the allocators do similar things after all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
