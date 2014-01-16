Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id EE78F6B0036
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 19:20:02 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so799421eak.30
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 16:20:02 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id r9si10834106eeo.107.2014.01.15.16.11.45
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 16:11:45 -0800 (PST)
Date: Thu, 16 Jan 2014 02:11:41 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCH 1/9] mm: slab/slub: use page->list consistently
 instead of page->lru
Message-ID: <20140116001141.GA8456@node.dhcp.inet.fi>
References: <20140114180042.C1C33F78@viggo.jf.intel.com>
 <20140114180044.1E401C47@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140114180044.1E401C47@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org

On Tue, Jan 14, 2014 at 10:00:44AM -0800, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> 'struct page' has two list_head fields: 'lru' and 'list'.
> Conveniently, they are unioned together.  This means that code
> can use them interchangably, which gets horribly confusing like
> with this nugget from slab.c:
> 
> >	list_del(&page->lru);
> >	if (page->active == cachep->num)
> >		list_add(&page->list, &n->slabs_full);
> 
> This patch makes the slab and slub code use page->lru
> universally instead of mixing ->list and ->lru.
> 
> So, the new rule is: page->lru is what the you use if you want to
> keep your page on a list.  Don't like the fact that it's not
> called ->list?  Too bad.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
