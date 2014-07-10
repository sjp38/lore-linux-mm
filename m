Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id D01576B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 00:37:58 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id tp5so1254270ieb.34
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 21:37:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w10si11141795igl.62.2014.07.09.21.37.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jul 2014 21:37:58 -0700 (PDT)
Date: Wed, 9 Jul 2014 21:37:38 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] mm/vmalloc.c: clean up map_vm_area third argument
Message-ID: <20140710043738.GA13532@kroah.com>
References: <1404721943-6506-1-git-send-email-chaowang@redhat.com>
 <1404966367-7599-1-git-send-email-chaowang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404966367-7599-1-git-send-email-chaowang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WANG Chao <chaowang@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Rusty Russell <rusty@rustcorp.com.au>, Chris Metcalf <cmetcalf@tilera.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 10, 2014 at 12:26:07PM +0800, WANG Chao wrote:
> Currently map_vm_area() takes (struct page *** pages) as third argument,
> and after mapping, it moves (*pages) to point to (*pages + nr_mappped_pages).
> 
> It looks like this kind of increment is useless to its caller these
> days. The callers don't care about the increments and actually they're
> trying to avoid this by passing another copy to map_vm_area().
> 
> The caller can always guarantee all the pages can be mapped into
> vm_area as specified in first argument and the caller only cares about
> whether map_vm_area() fails or not.
> 
> This patch cleans up the pointer movement in map_vm_area() and updates
> its callers accordingly.
> 
> v2: Fix arch/tile/kernel/module.c::module_alloc().
> 
> Signed-off-by: WANG Chao <chaowang@redhat.com>
> ---
>  arch/tile/kernel/module.c        |  2 +-
>  drivers/lguest/core.c            |  7 ++-----
>  drivers/staging/android/binder.c |  4 +---
>  include/linux/vmalloc.h          |  2 +-
>  mm/vmalloc.c                     | 14 +++++---------
>  mm/zsmalloc.c                    |  2 +-
>  6 files changed, 11 insertions(+), 20 deletions(-)

Staging code:

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
