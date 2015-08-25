Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2D78B6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 13:10:19 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so21100791wid.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:10:18 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id o5si4376237wiv.71.2015.08.25.10.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 10:10:17 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so21436867wic.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:10:16 -0700 (PDT)
Date: Tue, 25 Aug 2015 20:10:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 2/4] zsmalloc: use page->private instead of
 page->first_page
Message-ID: <20150825171014.GA4881@node.dhcp.inet.fi>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439824145-25397-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20150825021735.GA412@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150825021735.GA412@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, Aug 25, 2015 at 11:17:35AM +0900, Sergey Senozhatsky wrote:
> On (08/17/15 18:09), Kirill A. Shutemov wrote:
> [..]
> > @@ -980,7 +979,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
> >  		if (i == 1)
> >  			set_page_private(first_page, (unsigned long)page);
> >  		if (i >= 1)
> > -			page->first_page = first_page;
> > +			set_page_private(first_page, (unsigned long)first_page);
> 
> This patch breaks zram/zsmalloc.
> 
> Shouldn't it be `page->private = first_page' instead of
> `first_page->private = first_page'? IOW:
> 
> -	set_page_private(first_page, (unsigned long)first_page);
> +	set_page_private(page, (unsigned long)first_page);
> 
> ?

Good catch. Thanks!

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
