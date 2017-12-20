Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E30D6B0069
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 18:39:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p190so3274820wmd.0
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 15:39:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n188si3752598wma.203.2017.12.20.15.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 15:39:10 -0800 (PST)
Date: Wed, 20 Dec 2017 15:39:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 6/8] mm: Store compound_dtor / compound_order as
 bytes
Message-Id: <20171220153907.7f3994967cba32c6f654982c@linux-foundation.org>
In-Reply-To: <20171220155552.15884-7-willy@infradead.org>
References: <20171220155552.15884-1-willy@infradead.org>
	<20171220155552.15884-7-willy@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Wed, 20 Dec 2017 07:55:50 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Neither of these values get even close to 256; compound_dtor is
> currently at a maximum of 3, and compound_order can't be over 64.
> No machine has inefficient access to bytes since EV5, and while
> those are still supported, we don't optimise for them any more.

So we couild fit compound_dtor and compound_order into a single byte if
desperate?

> This does not shrink struct page, but it removes an ifdef and
> frees up 2-6 bytes for future use.

Can we add a little comment telling readers "hey there's a gap here!"?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
