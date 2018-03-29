Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D59A06B0003
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 01:32:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p189so3313346pfp.1
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 22:32:49 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id o1-v6si5105892plb.459.2018.03.28.22.32.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 22:32:48 -0700 (PDT)
Subject: Re: [PATCHv2 08/14] mm/page_ext: Drop definition of unused
 PAGE_EXT_DEBUG_POISON
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-9-kirill.shutemov@linux.intel.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <765cf3b4-a2dd-39d4-6bf6-0096a9b6e818@codeaurora.org>
Date: Thu, 29 Mar 2018 11:02:42 +0530
MIME-Version: 1.0
In-Reply-To: <20180328165540.648-9-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 3/28/2018 10:25 PM, Kirill A. Shutemov wrote:
> After bd33ef368135 ("mm: enable page poisoning early at boot")
> PAGE_EXT_DEBUG_POISON is not longer used. Remove it.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Vinayak Menon <vinmenon@codeaurora.org>
> ---
>  include/linux/page_ext.h | 11 -----------
>  1 file changed, 11 deletions(-)
>
> diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
> index ca5461efae2f..bbec618a614b 100644
> --- a/include/linux/page_ext.h
> +++ b/include/linux/page_ext.h
> @@ -16,18 +16,7 @@ struct page_ext_operations {
>  
>  #ifdef CONFIG_PAGE_EXTENSION
>  
> -/*
> - * page_ext->flags bits:
> - *
> - * PAGE_EXT_DEBUG_POISON is set for poisoned pages. This is used to
> - * implement generic debug pagealloc feature. The pages are filled with
> - * poison patterns and set this flag after free_pages(). The poisoned
> - * pages are verified whether the patterns are not corrupted and clear
> - * the flag before alloc_pages().
> - */
> -
>  enum page_ext_flags {
> -	PAGE_EXT_DEBUG_POISON,		/* Page is poisoned */
>  	PAGE_EXT_DEBUG_GUARD,
>  	PAGE_EXT_OWNER,
>  #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)

Reviewed-by: Vinayak Menon <vinmenon@codeaurora.org>
