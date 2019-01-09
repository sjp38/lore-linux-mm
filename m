Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3624D8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:16:55 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id g16so609587lfb.22
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:16:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s22sor17248274lfb.46.2019.01.09.08.16.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 08:16:53 -0800 (PST)
MIME-Version: 1.0
References: <20190109161916.GA23410@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190109161916.GA23410@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 9 Jan 2019 21:50:44 +0530
Message-ID: <CAFqt6zbeHPs359c03q8wCENfW5DJ3W6_ber78fCmoQzYcUhpCQ@mail.gmail.com>
Subject: Re: [PATCH] include/linux/hmm.h: Convert to use vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: jglisse@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>

On Wed, Jan 9, 2019 at 9:45 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> convert to use vm_fault_t type as return type for
> fault handler.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

kbuild reported a warning during testing of final vm_fault_t patch integrated
in mm tree.

[auto build test WARNING on linus/master]
[also build test WARNING on v5.0-rc1 next-20190109]
[if your patch is applied to the wrong git tree, please drop us a note
to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Souptick-Joarder/mm-Create-the-new-vm_fault_t-type/20190109-154216

>> kernel/memremap.c:46:34: warning: incorrect type in return expression (different base types)
   kernel/memremap.c:46:34:    expected restricted vm_fault_t
   kernel/memremap.c:46:34:    got int

This patch has fixed the warning.

> ---
>  include/linux/hmm.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 66f9ebb..7c5ace3 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -468,7 +468,7 @@ struct hmm_devmem_ops {
>          * Note that mmap semaphore is held in read mode at least when this
>          * callback occurs, hence the vma is valid upon callback entry.
>          */
> -       int (*fault)(struct hmm_devmem *devmem,
> +       vm_fault_t (*fault)(struct hmm_devmem *devmem,
>                      struct vm_area_struct *vma,
>                      unsigned long addr,
>                      const struct page *page,
> --
> 1.9.1
>
