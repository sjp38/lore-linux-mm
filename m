Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5D3E8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 18:38:09 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id n186-v6so1028622oig.13
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 15:38:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4-v6sor1699489oia.175.2018.09.27.15.38.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 15:38:08 -0700 (PDT)
MIME-Version: 1.0
References: <1538086549-100536-1-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1538086549-100536-1-git-send-email-yang.shi@linux.alibaba.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 27 Sep 2018 15:37:56 -0700
Message-ID: <CAPcyv4jgNsqxKjaQNuY8t1FXcoNNThAoYuAvd=7Gg=JqvZHx3g@mail.gmail.com>
Subject: Re: [v2 PATCH] mm: dax: add comment for PFN_SPECIAL
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.shi@linux.alibaba.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Sep 27, 2018 at 3:17 PM <yang.shi@linux.alibaba.com> wrote:
>
> The comment for PFN_SPECIAL is missed in pfn_t.h. Add comment to get
> consistent with other pfn flags.
>
> Suggested-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> v2: rephrase the comment per Dan

Looks good for the -mm tree.

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

>
>  include/linux/pfn_t.h | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
> index 21713dc..d6cc4b5 100644
> --- a/include/linux/pfn_t.h
> +++ b/include/linux/pfn_t.h
> @@ -9,6 +9,8 @@
>   * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
>   * PFN_DEV - pfn is not covered by system memmap by default
>   * PFN_MAP - pfn has a dynamic page mapping established by a device driver
> + * PFN_SPECIAL - for CONFIG_FS_DAX_LIMITED builds to allow XIP, but not
> + *              get_user_pages
>   */
>  #define PFN_FLAGS_MASK (((u64) ~PAGE_MASK) << (BITS_PER_LONG_LONG - PAGE_SHIFT))
>  #define PFN_SG_CHAIN (1ULL << (BITS_PER_LONG_LONG - 1))
> --
> 1.8.3.1
>
