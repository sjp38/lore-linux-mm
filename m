Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9E16B0268
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 18:02:47 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j14so3076911wre.4
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 15:02:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m21si3968147wma.151.2017.10.18.15.02.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 15:02:46 -0700 (PDT)
Date: Wed, 18 Oct 2017 15:02:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Convert delete_from_page_cache_batch() to pagevec
Message-Id: <20171018150243.299f26922c2effdd3de89ea9@linux-foundation.org>
In-Reply-To: <20171018111648.13714-1-jack@suse.cz>
References: <20171018111648.13714-1-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, 18 Oct 2017 13:16:48 +0200 Jan Kara <jack@suse.cz> wrote:

> This is a patch to use pagevec instead of page array - to be folded into the
> last patch of my batched truncate series: "mm: Batch radix tree operations
> when truncating pages". Thanks!

That shrinks .text by 112 bytes.  Huh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
