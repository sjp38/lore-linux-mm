Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 612C56B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 01:26:13 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id va7so4710132obc.41
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 22:26:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374183272-10153-7-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1374183272-10153-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Fri, 19 Jul 2013 13:26:12 +0800
Message-ID: <CAJd=RBD4SNTpA=6ODXswGycBMq9LRhm=rZ4p2N7=RputH2O8bw@mail.gmail.com>
Subject: Re: [PATCH 6/8] migrate: remove VM_HUGETLB from vma flag check in vma_migratable()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jul 19, 2013 at 5:34 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> This patch enables hugepage migration from migrate_pages(2),
> move_pages(2), and mbind(2).
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---

Acked-by: Hillf Danton <dhillf@gmail.com>

>  include/linux/mempolicy.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git v3.11-rc1.orig/include/linux/mempolicy.h v3.11-rc1/include/linux/mempolicy.h
> index 0d7df39..2e475b5 100644
> --- v3.11-rc1.orig/include/linux/mempolicy.h
> +++ v3.11-rc1/include/linux/mempolicy.h
> @@ -173,7 +173,7 @@ extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
>  /* Check if a vma is migratable */
>  static inline int vma_migratable(struct vm_area_struct *vma)
>  {
> -       if (vma->vm_flags & (VM_IO | VM_HUGETLB | VM_PFNMAP))
> +       if (vma->vm_flags & (VM_IO | VM_PFNMAP))
>                 return 0;
>         /*
>          * Migration allocates pages in the highest zone. If we cannot
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
