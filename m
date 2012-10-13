Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 93BB16B0044
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 08:26:40 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so4577855vbk.14
        for <linux-mm@kvack.org>; Sat, 13 Oct 2012 05:26:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1349999637-8613-1-git-send-email-andi@firstfloor.org>
References: <1349999637-8613-1-git-send-email-andi@firstfloor.org>
Date: Sat, 13 Oct 2012 20:26:39 +0800
Message-ID: <CAJd=RBByzsGUaOxOoQpu_SN+K5XRxd2PEGhB48CHkuO5qJ5grA@mail.gmail.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v4
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

Hi Andi,

On Fri, Oct 12, 2012 at 7:53 AM, Andi Kleen <andi@firstfloor.org> wrote:
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 2251648..c626a2a 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -183,7 +183,13 @@ extern const struct file_operations hugetlbfs_file_operations;
>  extern const struct vm_operations_struct hugetlb_vm_ops;
>  struct file *hugetlb_file_setup(const char *name, unsigned long addr,
>                                 size_t size, vm_flags_t acct,
> -                               struct user_struct **user, int creat_flags);
> +                               struct user_struct **user, int creat_flags,
> +                               int page_size_log);
> +int hugetlb_get_quota(struct address_space *mapping, long delta);
> +void hugetlb_put_quota(struct address_space *mapping, long delta);
> +
> +int hugetlb_get_quota(struct address_space *mapping, long delta);
> +void hugetlb_put_quota(struct address_space *mapping, long delta);


For what to add(twice) hugetlb_get/put_quota?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
