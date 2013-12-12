Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id E82DF6B0037
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 08:16:44 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so495338pbb.4
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:16:44 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id g5si16512619pav.172.2013.12.12.05.16.40
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 05:16:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131211223632.8B2DFD41@viggo.jf.intel.com>
References: <20131211223631.51094A3D@viggo.jf.intel.com>
 <20131211223632.8B2DFD41@viggo.jf.intel.com>
Subject: RE: [PATCH 2/2] mm: blk-mq: uses page->list incorrectly
Content-Transfer-Encoding: 7bit
Message-Id: <20131212131636.B7C44E0090@blue.fi.intel.com>
Date: Thu, 12 Dec 2013 15:16:36 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@gentwo.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>, akpm@linux-foundation.org

Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> 'struct page' has two list_head fields: 'lru' and 'list'.
> Conveniently, they are unioned together.  This means that code
> can use them interchangably, which gets horribly confusing.
> 
> The blk-mq made the logical decision to try to use page->list.
> But, that field was actually introduced just for the slub code.
> ->lru is the right field to use outside of slab/slub.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

for both.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
