Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id AEE9A6B0036
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:40:01 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id m20so562080qcx.36
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 09:40:01 -0800 (PST)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTP id w9si8201298qad.44.2013.12.12.09.40.00
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 09:40:00 -0800 (PST)
Date: Thu, 12 Dec 2013 17:39:59 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: slab/slub: use page->list consistently instead
 of page->lru
In-Reply-To: <20131211223631.51094A3D@viggo.jf.intel.com>
Message-ID: <00000142e7e4c89c-f8f8fab4-687c-4fe0-b0ac-c4b9ec25d739-000000@email.amazonses.com>
References: <20131211223631.51094A3D@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>

On Wed, 11 Dec 2013, Dave Hansen wrote:

> 'struct page' has two list_head fields: 'lru' and 'list'.
> Conveniently, they are unioned together.  This means that code
> can use them interchangably, which gets horribly confusing like
> with this nugget from slab.c:

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
