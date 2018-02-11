Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E21476B000C
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 15:09:34 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w102so7759067wrb.21
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 12:09:34 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id n7si1206264wre.311.2018.02.11.12.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Feb 2018 12:09:33 -0800 (PST)
Date: Sun, 11 Feb 2018 12:09:28 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm/huge_memory.c: reorder operations in
 __split_huge_page_tail()
Message-ID: <20180211200928.GA4680@bombadil.infradead.org>
References: <4f64569f-b8ce-54f8-33d9-0e67216bb54c@yandex-team.ru>
 <151835937752.185602.5640977700089242532.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151835937752.185602.5640977700089242532.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>

On Sun, Feb 11, 2018 at 05:29:37PM +0300, Konstantin Khlebnikov wrote:
> +	/*
> +	 * Finally unfreeze refcount. Additional pin to radix tree.
> +	 */
> +	page_ref_unfreeze(page_tail, 1 + (!PageAnon(head) ||
> +					  PageSwapCache(head)));

Please say "Additional pin from page cache", not "radix tree".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
