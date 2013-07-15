Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 38E4A6B0033
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 09:12:15 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id n10so15858298oag.14
        for <linux-mm@kvack.org>; Mon, 15 Jul 2013 06:12:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1373881967-16153-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1373881967-16153-3-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 15 Jul 2013 21:12:14 +0800
Message-ID: <CAJd=RBAi5HDep42DQRdWOvzO4-Li=x_VDqC7FzYojmM0O7eAzg@mail.gmail.com>
Subject: Re: [PATCH 2/9] mm, hugetlb: trivial commenting fix
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 5:52 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> The name of the mutex written in comment is wrong.
> Fix it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
Acked-by: Hillf Danton <dhillf@gmail.com>

> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index d87f70b..d21a33a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -135,9 +135,9 @@ static inline struct hugepage_subpool *subpool_vma(struct vm_area_struct *vma)
>   *                    across the pages in a mapping.
>   *
>   * The region data structures are protected by a combination of the mmap_sem
> - * and the hugetlb_instantion_mutex.  To access or modify a region the caller
> + * and the hugetlb_instantiation_mutex.  To access or modify a region the caller
>   * must either hold the mmap_sem for write, or the mmap_sem for read and
> - * the hugetlb_instantiation mutex:
> + * the hugetlb_instantiation_mutex:
>   *
>   *     down_write(&mm->mmap_sem);
>   * or
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
