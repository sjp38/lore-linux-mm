Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7717E6B0044
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 23:43:54 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so406589pad.31
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 20:43:54 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id iw3si269120pac.55.2014.04.07.19.01.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 19:01:44 -0700 (PDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F181F3EE1D3
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:01:42 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD49A45DF4C
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:01:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.nic.fujitsu.com [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C15E545DF48
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:01:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B41721DB8042
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:01:42 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 640871DB803E
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:01:42 +0900 (JST)
Message-ID: <5343585D.1020206@jp.fujitsu.com>
Date: Tue, 8 Apr 2014 11:01:01 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] hugetlb: update_and_free_page(): don't clear PG_reserved
 bit
References: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com> <1396462128-32626-3-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1396462128-32626-3-git-send-email-lcapitulino@redhat.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, yinghai@kernel.org, riel@redhat.com

(2014/04/03 3:08), Luiz Capitulino wrote:
> Hugepages pages never get the PG_reserved bit set, so don't clear it. But
> add a warning just in case.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> ---

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>   mm/hugetlb.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 8c50547..7e07e47 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -581,8 +581,9 @@ static void update_and_free_page(struct hstate *h, struct page *page)
>   	for (i = 0; i < pages_per_huge_page(h); i++) {
>   		page[i].flags &= ~(1 << PG_locked | 1 << PG_error |
>   				1 << PG_referenced | 1 << PG_dirty |
> -				1 << PG_active | 1 << PG_reserved |
> -				1 << PG_private | 1 << PG_writeback);
> +				1 << PG_active | 1 << PG_private |
> +				1 << PG_writeback);
> +		WARN_ON(PageReserved(&page[i]));
>   	}
>   	VM_BUG_ON_PAGE(hugetlb_cgroup_from_page(page), page);
>   	set_compound_page_dtor(page, NULL);
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
