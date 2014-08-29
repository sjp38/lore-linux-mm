Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 228F46B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 17:10:07 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id x3so3061719qcv.30
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 14:10:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w8si1794992qas.110.2014.08.29.14.10.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 14:10:06 -0700 (PDT)
Date: Fri, 29 Aug 2014 17:09:56 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 7/7] mm/balloon_compaction: general cleanup
Message-ID: <20140829210955.GB11878@t510.redhat.com>
References: <20140820150435.4194.28003.stgit@buzz>
 <20140820150509.4194.24336.stgit@buzz>
 <20140829140521.ca9b1dc87c8bc4b075f5b083@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140829140521.ca9b1dc87c8bc4b075f5b083@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

On Fri, Aug 29, 2014 at 02:05:21PM -0700, Andrew Morton wrote:
> On Wed, 20 Aug 2014 19:05:09 +0400 Konstantin Khlebnikov <k.khlebnikov@samsung.com> wrote:
> 
> > * move special branch for balloon migraion into migrate_pages
> > * remove special mapping for balloon and its flag AS_BALLOON_MAP
> > * embed struct balloon_dev_info into struct virtio_balloon
> > * cleanup balloon_page_dequeue, kill balloon_page_free
> > 
> 
> grump.
> 
> diff -puN include/linux/balloon_compaction.h~mm-balloon_compaction-general-cleanup-fix include/linux/balloon_compaction.h
> --- a/include/linux/balloon_compaction.h~mm-balloon_compaction-general-cleanup-fix
> +++ a/include/linux/balloon_compaction.h
> @@ -145,7 +145,7 @@ static inline void
>  balloon_page_insert(struct balloon_dev_info *balloon, struct page *page)
>  {
>  	__SetPageBalloon(page);
> -	list_add(&page->lru, head);
> +	list_add(&page->lru, &balloon->pages);
>  }
>  
>  static inline void balloon_page_delete(struct page *page, bool isolated)
> 
> 
> This obviously wasn't tested with CONFIG_BALLOON_COMPACTION=n.  Please
> complete the testing of this patchset and let us know the result?
>

That also reminds me why I suggested moving those as static inlines into mm.h, 
instead of getting them hidden in mm/balloon_compaction.c

Cheers,
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
