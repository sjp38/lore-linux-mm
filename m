Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 17D0E6B0254
	for <linux-mm@kvack.org>; Sun, 30 Aug 2015 21:30:13 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so121039359pab.1
        for <linux-mm@kvack.org>; Sun, 30 Aug 2015 18:30:12 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id j9si21381336pbq.42.2015.08.30.18.30.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Aug 2015 18:30:12 -0700 (PDT)
Received: by pabzx8 with SMTP id zx8so121038812pab.1
        for <linux-mm@kvack.org>; Sun, 30 Aug 2015 18:30:11 -0700 (PDT)
Date: Mon, 31 Aug 2015 10:30:52 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCHv4 3/7] zsmalloc: use page->private instead of
 page->first_page
Message-ID: <20150831013052.GA2168@swordfish>
References: <1440683961-32839-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1440683961-32839-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440683961-32839-4-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (08/27/15 16:59), Kirill A. Shutemov wrote:
> We are going to rework how compound_head() work. It will not use
> page->first_page as we have it now.
> 
> The only other user of page->first_page beyond compound pages is
> zsmalloc.
> 
> Let's use page->private instead of page->first_page here. It occupies
> the same storage space.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
