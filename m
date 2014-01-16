Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id A12AF6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 19:17:00 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so801362eaj.23
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 16:17:00 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id r9si10876265eeo.65.2014.01.15.16.16.59
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 16:16:59 -0800 (PST)
Date: Thu, 16 Jan 2014 02:16:54 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCH 3/9] mm: page->pfmemalloc only used by slab/skb
Message-ID: <20140116001654.GB8456@node.dhcp.inet.fi>
References: <20140114180042.C1C33F78@viggo.jf.intel.com>
 <20140114180051.0181E467@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140114180051.0181E467@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org

On Tue, Jan 14, 2014 at 10:00:51AM -0800, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> page->pfmemalloc does not deserve a spot in 'struct page'.  It is
> only used transiently _just_ after a page leaves the buddy
> allocator.
> 
> Instead of declaring a union, we move its functionality behind a
> few quick accessor functions.  This way we could also much more
> easily audit that it is being used correctly in debugging
> scenarios.  For instance, we could store a magic number in there
> which could never get reused as a page->index and check that the
> magic number exists in page_pfmemalloc().
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
