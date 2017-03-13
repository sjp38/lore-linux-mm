Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43C9E6B0389
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:57:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e5so295424571pgk.1
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 04:57:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o1si302819pld.43.2017.03.13.04.57.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 04:57:05 -0700 (PDT)
Date: Mon, 13 Mar 2017 04:57:02 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: don't warn when vmalloc() fails due to a fatal signal
Message-ID: <20170313115702.GA4033@bombadil.infradead.org>
References: <20170313114425.72724-1-dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313114425.72724-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: aryabinin@virtuozzo.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, Mar 13, 2017 at 12:44:25PM +0100, Dmitry Vyukov wrote:
> When vmalloc() fails it prints a very lengthy message with all the
> details about memory consumption assuming that it happened due to OOM.
> However, vmalloc() can also fail due to fatal signal pending.
> In such case the message is quite confusing because it suggests that
> it is OOM but the numbers suggest otherwise. The messages can also
> pollute console considerably.
> 
> Don't warn when vmalloc() fails due to fatal signal pending.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
