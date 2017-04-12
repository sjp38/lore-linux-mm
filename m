Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F61F6B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 13:32:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c198so13103274pfc.19
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 10:32:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v26si917511pgn.161.2017.04.12.10.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 10:32:22 -0700 (PDT)
Date: Wed, 12 Apr 2017 10:31:51 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: add VM_STATIC flag to vmalloc and prevent from
 removing the areas
Message-ID: <20170412173151.GA23054@infradead.org>
References: <1491973350-26816-1-git-send-email-hoeun.ryu@gmail.com>
 <20170412060218.GA16170@infradead.org>
 <AC5E3048-6E2B-4DBE-80BA-AAE2D3EED969@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AC5E3048-6E2B-4DBE-80BA-AAE2D3EED969@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hoeun Ryu <hoeun.ryu@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andreas Dilger <adilger@dilger.ca>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Chris Wilson <chris@chris-wilson.co.uk>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Matthew Wilcox <mawilcox@microsoft.com>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 12, 2017 at 08:42:08PM +0900, Hoeun Ryu wrote:
> 
> > On Apr 12, 2017, at 3:02 PM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> >> On Wed, Apr 12, 2017 at 02:01:59PM +0900, Hoeun Ryu wrote:
> >> vm_area_add_early/vm_area_register_early() are used to reserve vmalloc area
> >> during boot process and those virtually mapped areas are never unmapped.
> >> So `OR` VM_STATIC flag to the areas in vmalloc_init() when importing
> >> existing vmlist entries and prevent those areas from being removed from the
> >> rbtree by accident.
> > 
> > How would they be removed "by accident"?
> 
> I don't mean actual use-cases, but I just want to make it robust against like programming errors.

Oh, ok.  The patch makes sense then, although the changelog could use
a little update.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
