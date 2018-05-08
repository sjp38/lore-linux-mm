Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2C76B02DF
	for <linux-mm@kvack.org>; Tue,  8 May 2018 17:44:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s3so25143088pfh.0
        for <linux-mm@kvack.org>; Tue, 08 May 2018 14:44:50 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v12-v6si24378471plo.264.2018.05.08.14.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 14:44:49 -0700 (PDT)
Date: Wed, 9 May 2018 00:44:45 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v2] x86/boot/64/clang: Use fixup_pointer() to access
 '__supported_pte_mask'
Message-ID: <20180508214445.lnqbct6dgrhyxp4a@black.fi.intel.com>
References: <20180508162829.7729-1-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180508162829.7729-1-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: dave.hansen@linux.intel.com, mingo@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mka@chromium.org, dvyukov@google.com, md@google.com

On Tue, May 08, 2018 at 04:28:29PM +0000, Alexander Potapenko wrote:
> @@ -196,7 +204,8 @@ unsigned long __head __startup_64(unsigned long physaddr,
>  
>  	pmd_entry = __PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL;
>  	/* Filter out unsupported __PAGE_KERNEL_* bits: */
> -	pmd_entry &= __supported_pte_mask;
> +	mask_ptr = (pteval_t *)fixup_pointer(&__supported_pte_mask, physaddr);

Do we really need the cast here?

-- 
 Kirill A. Shutemov
