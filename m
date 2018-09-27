Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6945F8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 17:09:03 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id c24-v6so4925612otm.4
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 14:09:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h16-v6sor1490411oih.162.2018.09.27.14.09.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 14:09:02 -0700 (PDT)
MIME-Version: 1.0
References: <1538077089-14550-1-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1538077089-14550-1-git-send-email-yang.shi@linux.alibaba.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 27 Sep 2018 14:08:51 -0700
Message-ID: <CAPcyv4jvmTUUgVXd7gCVcmMbOM0OcY8rTQGkp+Ak1NHpi+zS_g@mail.gmail.com>
Subject: Re: [PATCH] mm: dax: add comment for PFN_SPECIAL
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.shi@linux.alibaba.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Sep 27, 2018 at 12:39 PM <yang.shi@linux.alibaba.com> wrote:
>
> The comment for PFN_SPECIAL is missed in pfn_t.h. Add comment to get
> consistent with other pfn flags.
>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  include/linux/pfn_t.h | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
> index 21713dc..d2e5dd4 100644
> --- a/include/linux/pfn_t.h
> +++ b/include/linux/pfn_t.h
> @@ -9,6 +9,7 @@
>   * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
>   * PFN_DEV - pfn is not covered by system memmap by default
>   * PFN_MAP - pfn has a dynamic page mapping established by a device driver
> + * PFN_SPECIAL - indicates that _PAGE_SPECIAL should be used for DAX ptes

That's not quite accurate, I would change this to:

PFN_SPECIAL - for CONFIG_FS_DAX_LIMITED builds to allow XIP, but not
get_user_pages.
