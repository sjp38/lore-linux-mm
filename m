Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id CF7766B0037
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 19:20:03 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so796407eae.5
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 16:20:03 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id n47si10794866eey.224.2014.01.15.16.20.03
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 16:20:03 -0800 (PST)
Date: Thu, 16 Jan 2014 02:20:01 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCH 5/9] mm: rearrange struct page
Message-ID: <20140116002001.GC8456@node.dhcp.inet.fi>
References: <20140114180042.C1C33F78@viggo.jf.intel.com>
 <20140114180055.21691733@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140114180055.21691733@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org

On Tue, Jan 14, 2014 at 10:00:55AM -0800, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> To make the layout of 'struct page' look nicer, I broke
> up a few of the unions.  But, this has a cost: things that
> were guaranteed to line up before might not any more.  To make up
> for that, some BUILD_BUG_ON()s are added to manually check for
> the alignment dependencies.
> 
> This makes it *MUCH* more clear how the first few fields of
> 'struct page' get used by the slab allocators.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Looks much cleaner!

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
