Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0F16B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 19:26:01 -0500 (EST)
Received: by wmec201 with SMTP id c201so3670113wme.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 16:26:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i7si7865511wjf.134.2015.12.02.16.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 16:26:00 -0800 (PST)
Date: Wed, 2 Dec 2015 16:25:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: EXPORT_SYMBOL_GPL(find_vm_area);
Message-Id: <20151202162558.d0465f11746ff94114c5d987@linux-foundation.org>
In-Reply-To: <1447247184-27939-1-git-send-email-sakari.ailus@linux.intel.com>
References: <1447247184-27939-1-git-send-email-sakari.ailus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: linux-mm@kvack.org

On Wed, 11 Nov 2015 15:06:24 +0200 Sakari Ailus <sakari.ailus@linux.intel.com> wrote:

> find_vm_area() is needed in implementing the DMA mapping API as a module.
> Device specific IOMMUs with associated DMA mapping implementations should be
> buildable as modules.
> 
> ...
>
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1416,6 +1416,7 @@ struct vm_struct *find_vm_area(const void *addr)
>  
>  	return NULL;
>  }
> +EXPORT_SYMBOL_GPL(find_vm_area);

Confused.  Who is setting CONFIG_HAS_DMA=m?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
