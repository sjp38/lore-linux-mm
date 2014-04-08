Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9432B6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 19:58:31 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so1679117pde.10
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 16:58:30 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id j4si1795197pad.104.2014.04.08.16.58.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 16:58:29 -0700 (PDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D73663EE0B6
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 08:58:27 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C0AED45DE63
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 08:58:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D8A145DE55
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 08:58:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E1241DB804C
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 08:58:27 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E5B61DB8040
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 08:58:27 +0900 (JST)
Message-ID: <53448CD6.4030508@jp.fujitsu.com>
Date: Wed, 9 Apr 2014 08:57:10 +0900
From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hugetlb.c: add cond_resched_lock() in return_unused_surplus_pages()
References: <534462dd./BWAtkVlKQGnheFN%akpm@linux-foundation.org> <1396991970-aj1xjt2j@n-horiguchi@ah.jp.nec.com> <6B2BA408B38BA1478B473C31C3D2074E30981E3EDC@SV-EXCHANGE1.Corp.FC.LOCAL> <1396993585-zmuon97j@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1396993585-zmuon97j@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, akpm@linux-foundation.org, Motohiro.Kosaki@us.fujitsu.com
Cc: mhocko@suse.cz, kosaki.motohiro@jp.fujitsu.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org

Hi Naoya,

On Tue, 8 Apr 2014 17:46:25 -0400 Naoya Horiguchi wrote:
> On Tue, Apr 08, 2014 at 02:21:22PM -0700, Motohiro Kosaki wrote:
>> Naoya
>>
>>> -----Original Message-----
>>> From: Naoya Horiguchi [mailto:n-horiguchi@ah.jp.nec.com]
>>> Sent: Tuesday, April 08, 2014 5:20 PM
>>> To: akpm@linux-foundation.org
>>> Cc: mhocko@suse.cz; Motohiro Kosaki JP; iamjoonsoo.kim@lge.com; aneesh.kumar@linux.vnet.ibm.com; m.mizuma@jp.fujitsu.com
>>> Subject: Re: [merged] mm-hugetlb-fix-softlockup-when-a-large-number-of-hugepages-are-freed.patch removed from -mm tree
>>>
>>> Hi Andrew,
>>> # off list
>>>
>>> This patch is obsolete and latest version is ver.2.
>>> http://www.spinics.net/lists/linux-mm/msg71283.html
>>> Could you queue the new one to go to mainline?
>>
>> [merged] mean the patch has already been merged the linus tree. So, it can be changed. Please make
>> an incremental patch.
> 
> Here it is.

Thank you for posting this incremental patch! 

Thanks,
Masayoshi Mizuma

> 
> Thanks,
> Naoya Horiguchi
> ---
> Subject: [PATCH] mm/hugetlb.c: add cond_resched_lock() in return_unused_surplus_pages()
> 
> From: "Mizuma, Masayoshi" <m.mizuma@jp.fujitsu.com>
> 
> soft lockup in freeing gigantic hugepage fixed in commit 55f67141a892
> "mm: hugetlb: fix softlockup when a large number of hugepages are freed."
> can happen in return_unused_surplus_pages(), so let's fix it.
> 
> Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: <stable@vger.kernel.org>
> ---
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7d57af2..761ef5b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1160,6 +1160,7 @@ static void return_unused_surplus_pages(struct hstate *h,
>   	while (nr_pages--) {
>   		if (!free_pool_huge_page(h, &node_states[N_MEMORY], 1))
>   			break;
> +		cond_resched_lock(&hugetlb_lock);
>   	}
>   }
>   
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
