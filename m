Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id EF5306B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 05:30:18 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id up14so743141obb.11
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 02:30:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375075701-5998-6-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1375075701-5998-6-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 29 Jul 2013 17:30:17 +0800
Message-ID: <CAJd=RBC5XwDp9p1b48EgkfRAQ=zVj0=TG_qFQrQ325RsFM5zsQ@mail.gmail.com>
Subject: Re: [PATCH v3 5/9] mm, hugetlb: remove redundant list_empty check in gather_surplus_pages()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Mon, Jul 29, 2013 at 1:28 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> If list is empty, list_for_each_entry_safe() doesn't do anything.
> So, this check is redundant. Remove it.
>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
Acked-by: Hillf Danton <dhillf@gmail.com>

> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 87d7637..2e52afea 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1020,11 +1020,8 @@ free:
>         spin_unlock(&hugetlb_lock);
>
>         /* Free unnecessary surplus pages to the buddy allocator */
> -       if (!list_empty(&surplus_list)) {
> -               list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
> -                       put_page(page);
> -               }
> -       }
> +       list_for_each_entry_safe(page, tmp, &surplus_list, lru)
> +               put_page(page);
>         spin_lock(&hugetlb_lock);
>
>         return ret;
> --
> 1.7.9.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
