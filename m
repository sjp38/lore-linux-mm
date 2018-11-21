Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16DA66B27D7
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 17:11:03 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 89so11052916ple.19
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 14:11:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q71-v6si56425074pfq.166.2018.11.21.14.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Nov 2018 14:11:02 -0800 (PST)
Date: Wed, 21 Nov 2018 14:11:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3] mm: use swp_offset as key in shmem_replace_page()
Message-ID: <20181121221100.GM3065@bombadil.infradead.org>
References: <20181119010924.177177-1-yuzhao@google.com>
 <20181121215442.138545-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121215442.138545-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 21, 2018 at 02:54:42PM -0700, Yu Zhao wrote:
> We changed key of swap cache tree from swp_entry_t.val to
> swp_offset. Need to do so in shmem_replace_page() as well.
> 
> Fixes: f6ab1f7f6b2d ("mm, swap: use offset of swap entry as key of swap cache")
> Cc: stable@vger.kernel.org # v4.9+
> Signed-off-by: Yu Zhao <yuzhao@google.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>
