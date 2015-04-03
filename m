Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 01DB86B0032
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 03:20:32 -0400 (EDT)
Received: by pddn5 with SMTP id n5so113780475pdd.2
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 00:20:31 -0700 (PDT)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-251.mail.alibaba.com. [205.204.113.251])
        by mx.google.com with ESMTP id m13si10728198pby.164.2015.04.03.00.20.28
        for <linux-mm@kvack.org>;
        Fri, 03 Apr 2015 00:20:30 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <057a01d06ddd$ff2550e0$fd6ff2a0$@alibaba-inc.com>
In-Reply-To: <057a01d06ddd$ff2550e0$fd6ff2a0$@alibaba-inc.com>
Subject: Re: [patch -mm] mm, doc: cleanup and clarify munmap behavior for hugetlb memory fix
Date: Fri, 03 Apr 2015 15:18:50 +0800
Message-ID: <057b01d06dde$71738db0$545aa910$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

> 
> Don't only specify munmap(2) behavior with respect the hugetlb memory, all
> other syscalls get naturally aligned to the native page size of the
> processor.  Rather, pick out munmap(2) as a specific example.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  Documentation/vm/hugetlbpage.txt | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
> index 1270fb1..030977f 100644
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -313,8 +313,11 @@ into /proc/sys/vm/hugetlb_shm_group.  It is possible for same or different
>  applications to use any combination of mmaps and shm* calls, though the mount of
>  filesystem will be required for using mmap calls without MAP_HUGETLB.
> 
> -When using munmap(2) to unmap hugetlb memory, the length specified must be
> -hugepage aligned, otherwise it will fail with errno set to EINVAL.
> +Syscalls that operate on memory backed by hugetlb pages only have their lengths
> +aligned to the native page size of the processor; they will normally fail with
> +errno set to EINVAL or exclude hugetlb pages that extend beyond the length if
> +not hugepage aligned.  For example, munmap(2) will fail if memory is backed by
> +a hugetlb page and the length is smaller than the hugepage size.
> 
> 
>  Examples
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
