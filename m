Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1A06B30DA
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:56:50 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h86-v6so4825854pfd.2
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 02:56:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor24199861pll.68.2018.11.23.02.56.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 02:56:49 -0800 (PST)
Date: Fri, 23 Nov 2018 13:56:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] page cache: Store only head pages in i_pages
Message-ID: <20181123105643.fxqk7l57rdurdubx@kshutemo-mobl1>
References: <20181122213224.12793-1-willy@infradead.org>
 <20181122213224.12793-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122213224.12793-3-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Thu, Nov 22, 2018 at 01:32:24PM -0800, Matthew Wilcox wrote:
> Transparent Huge Pages are currently stored in i_pages as pointers to
> consecutive subpages.  This patch changes that to storing consecutive
> pointers to the head page in preparation for storing huge pages more
> efficiently in i_pages.

I probably miss something, I don't see how it wouldn't break
split_huge_page().

I don't see what would replace head pages in i_pages with
formerly-tail-pages?

Hm?

-- 
 Kirill A. Shutemov
