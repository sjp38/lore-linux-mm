Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9D16B0006
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 12:47:54 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b7-v6so2049109qtp.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 09:47:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u40-v6sor1190416qtc.108.2018.08.02.09.47.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Aug 2018 09:47:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1533195441-58594-1-git-send-email-chenjie6@huawei.com>
References: <1533195441-58594-1-git-send-email-chenjie6@huawei.com>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 2 Aug 2018 09:47:52 -0700
Message-ID: <CAHbLzkpj9chSMFWWhSb1hTL86rWdys3a=2oHgLjp_e-mDGF1Sw@mail.gmail.com>
Subject: Re: [PATCH] mm:bugfix check return value of ioremap_prot
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chenjie6@huawei.com
Cc: linux-mm@kvack.org, tj@kernel.org, Andrew Morton <akpm@linux-foundation.org>, lizefan@huawei.com, chen jie <"chen jie@chenjie6"@huwei.com>

On Thu, Aug 2, 2018 at 12:37 AM,  <chenjie6@huawei.com> wrote:
> From: chen jie <chen jie@chenjie6@huwei.com>
>
>         ioremap_prot can return NULL which could lead to an oops

What oops? You'd better to have the oops information in your commit log.

Thanks,
Yang

>
> Signed-off-by: chen jie <chenjie6@huawei.com>
> ---
>  mm/memory.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 7206a63..316c42e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4397,6 +4397,9 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
>                 return -EINVAL;
>
>         maddr = ioremap_prot(phys_addr, PAGE_ALIGN(len + offset), prot);
> +       if (!maddr)
> +               return -ENOMEM;
> +
>         if (write)
>                 memcpy_toio(maddr + offset, buf, len);
>         else
> --
> 1.8.3.4
>
