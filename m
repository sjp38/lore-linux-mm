Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58A276B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 02:02:39 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u202so10686127pgb.9
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 23:02:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g17si19206691pgj.222.2017.04.11.23.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 23:02:36 -0700 (PDT)
Date: Tue, 11 Apr 2017 23:02:18 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: add VM_STATIC flag to vmalloc and prevent from
 removing the areas
Message-ID: <20170412060218.GA16170@infradead.org>
References: <1491973350-26816-1-git-send-email-hoeun.ryu@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1491973350-26816-1-git-send-email-hoeun.ryu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hoeun Ryu <hoeun.ryu@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andreas Dilger <adilger@dilger.ca>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Chris Wilson <chris@chris-wilson.co.uk>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Matthew Wilcox <mawilcox@microsoft.com>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 12, 2017 at 02:01:59PM +0900, Hoeun Ryu wrote:
> vm_area_add_early/vm_area_register_early() are used to reserve vmalloc area
> during boot process and those virtually mapped areas are never unmapped.
> So `OR` VM_STATIC flag to the areas in vmalloc_init() when importing
> existing vmlist entries and prevent those areas from being removed from the
> rbtree by accident.

How would they be removed "by accident"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
