Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAC824403D7
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 12:47:32 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id x62so4812366iod.7
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 09:47:32 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j9si6295748iof.109.2017.12.16.09.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 09:47:28 -0800 (PST)
Subject: Re: [PATCH 7/8] mm: Document how to use struct page
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-8-willy@infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <4d963b8f-0010-fd20-013e-f53f27c8a7ce@infradead.org>
Date: Sat, 16 Dec 2017 09:47:16 -0800
MIME-Version: 1.0
In-Reply-To: <20171216164425.8703-8-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On 12/16/2017 08:44 AM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Be really explicit about what bits / bytes are reserved for users that
> want to store extra information about the pages they allocate.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/mm_types.h | 23 ++++++++++++++++++++++-
>  1 file changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 1a3ba1f1605d..a517d210f177 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -31,7 +31,28 @@ struct hmm;
>   * it to keep track of whatever it is we are using the page for at the
>   * moment. Note that we have no way to track which tasks are using
>   * a page, though if it is a pagecache page, rmap structures can tell us
> - * who is mapping it.
> + * who is mapping it. If you allocate the page using alloc_pages(), you
> + * can use some of the space in struct page for your own purposes.
> + *
> + * Pages that were once in the page cache may be found under the RCU lock
> + * even after they have been recycled to a different purpose.  The page cache
> + * will read and writes some of the fields in struct page to lock the page,

"will read and writes" seems awkward to me.
Can that be:
    * reads and writes

> + * then check that it's still in the page cache.  It is vital that all users
> + * of struct page:
ta.
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
