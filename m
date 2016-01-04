Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 35CF76B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 09:08:17 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id u188so148221547wmu.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 06:08:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h16si96859033wjn.237.2016.01.04.06.08.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 06:08:15 -0800 (PST)
Subject: Re: [PATCH] mm: Fix missing #include in <linux/mmdebug.h>
References: <20151219203034.GR28542@decadent.org.uk>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568A7CCD.2090407@suse.cz>
Date: Mon, 4 Jan 2016 15:08:13 +0100
MIME-Version: 1.0
In-Reply-To: <20151219203034.GR28542@decadent.org.uk>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>, linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org

On 12/19/2015 09:30 PM, Ben Hutchings wrote:
> The various VM_WARN_ON/VM_BUG_ON macros depend on those defined by
> <linux/bug.h>.  Most users already include those, but not all; for
> example:
>
>    CC      arch/arm64/xen/../../arm/xen/grant-table.o
> In file included from arch/arm64/include/../../arm/include/asm/xen/page.h:5:0,
>                   from arch/arm64/include/asm/xen/page.h:1,
>                   from include/xen/page.h:28,
>                   from arch/arm64/xen/../../arm/xen/grant-table.c:33:
> arch/arm64/include/asm/pgtable.h: In function 'set_pte_at':
> arch/arm64/include/asm/pgtable.h:281:3: error: implicit declaration of function 'BUILD_BUG_ON_INVALID' [-Werror=implicit-function-declaration]
>     VM_WARN_ONCE(!pte_young(pte),
>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   include/linux/mmdebug.h | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index 877ef22..772362a 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -1,6 +1,7 @@
>   #ifndef LINUX_MM_DEBUG_H
>   #define LINUX_MM_DEBUG_H 1
>
> +#include <linux/bug.h>
>   #include <linux/stringify.h>
>
>   struct page;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
