Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C928F6B0260
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 09:42:04 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id l124so85637514wmf.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 06:42:04 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id y5si10337614wjx.10.2016.03.17.06.42.03
        for <linux-mm@kvack.org>;
        Thu, 17 Mar 2016 06:42:03 -0700 (PDT)
Date: Thu, 17 Mar 2016 13:41:56 +0000
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH v2] mm/vmap: Add a notifier for when we run out of vmap
 address space
Message-ID: <20160317134156.GX14143@nuc-i3427.alporthouse.com>
References: <1458215982-13405-1-git-send-email-chris@chris-wilson.co.uk>
 <1458221699-13734-1-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458221699-13734-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Roman Peniaev <r.peniaev@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 17, 2016 at 01:34:59PM +0000, Chris Wilson wrote:
> vmaps are temporary kernel mappings that may be of long duration.
> Reusing a vmap on an object is preferrable for a driver as the cost of
> setting up the vmap can otherwise dominate the operation on the object.
> However, the vmap address space is rather limited on 32bit systems and
> so we add a notification for vmap pressure in order for the driver to
> release any cached vmappings.
> 
> The interface is styled after the oom-notifier where the callees are
> passed a pointer to an unsigned long counter for them to indicate if they
> have freed any space.
> 
> v2: Guard the blocking notifier call with gfpflags_allow_blocking()
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Roman Peniaev <r.peniaev@gmail.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  include/linux/vmalloc.h |  4 ++++
>  mm/vmalloc.c            | 27 +++++++++++++++++++++++++++
>  2 files changed, 31 insertions(+)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index d1f1d338af20..edd676b8e112 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -187,4 +187,8 @@ pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
>  #define VMALLOC_TOTAL 0UL
>  #endif
>  
> +struct notitifer_block;
Omg. /o\
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
