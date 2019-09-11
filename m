Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62338C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 10:24:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1854D2082C
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 10:24:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1854D2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB85F6B0007; Wed, 11 Sep 2019 06:24:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6ACA6B0008; Wed, 11 Sep 2019 06:24:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A58446B000A; Wed, 11 Sep 2019 06:24:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id 867C86B0007
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 06:24:30 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2A79568BF
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:24:30 +0000 (UTC)
X-FDA: 75922255500.18.lock77_4450a7da02506
X-HE-Tag: lock77_4450a7da02506
X-Filterd-Recvd-Size: 11033
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:24:29 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7DB29C00A167;
	Wed, 11 Sep 2019 10:24:28 +0000 (UTC)
Received: from [10.36.117.155] (ovpn-117-155.ams2.redhat.com [10.36.117.155])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2465660852;
	Wed, 11 Sep 2019 10:24:26 +0000 (UTC)
Subject: Re: [PATCH 05/10] mm: remove flag argument from soft offline
 functions
To: Oscar Salvador <osalvador@suse.de>, n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190910103016.14290-1-osalvador@suse.de>
 <20190910103016.14290-6-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <fee5249c-c3e7-9f86-3c6a-a51f69a9ae2a@redhat.com>
Date: Wed, 11 Sep 2019 12:24:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190910103016.14290-6-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 11 Sep 2019 10:24:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.09.19 12:30, Oscar Salvador wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> The argument @flag no longer affects the behavior of soft_offline_page()
> and its variants, so let's remove them.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  drivers/base/memory.c |  2 +-
>  include/linux/mm.h    |  2 +-
>  mm/madvise.c          |  2 +-
>  mm/memory-failure.c   | 27 +++++++++++++--------------
>  4 files changed, 16 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 6bea4f3f8040..e5485c22ef77 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -540,7 +540,7 @@ static ssize_t soft_offline_page_store(struct device *dev,
>  	pfn >>= PAGE_SHIFT;
>  	if (!pfn_valid(pfn))
>  		return -ENXIO;
> -	ret = soft_offline_page(pfn_to_page(pfn), 0);
> +	ret = soft_offline_page(pfn_to_page(pfn));
>  	return ret == 0 ? count : ret;
>  }
>  
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index fb36a4165a4e..3cc800d9f57a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2827,7 +2827,7 @@ extern int sysctl_memory_failure_early_kill;
>  extern int sysctl_memory_failure_recovery;
>  extern void shake_page(struct page *p, int access);
>  extern atomic_long_t num_poisoned_pages __read_mostly;
> -extern int soft_offline_page(struct page *page, int flags);
> +extern int soft_offline_page(struct page *page);
>  
>  
>  /*
> diff --git a/mm/madvise.c b/mm/madvise.c
> index fbe6d402232c..ece128211400 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -906,7 +906,7 @@ static int madvise_inject_error(int behavior,
>  			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
>  					pfn, start);
>  
> -			ret = soft_offline_page(page, 0);
> +			ret = soft_offline_page(page);
>  			if (ret)
>  				return ret;
>  			continue;
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 1be785b25324..5071d39bdfef 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1478,7 +1478,7 @@ static void memory_failure_work_func(struct work_struct *work)
>  		if (!gotten)
>  			break;
>  		if (entry.flags & MF_SOFT_OFFLINE)
> -			soft_offline_page(pfn_to_page(entry.pfn), entry.flags);
> +			soft_offline_page(pfn_to_page(entry.pfn));
>  		else
>  			memory_failure(entry.pfn, entry.flags);
>  	}
> @@ -1611,7 +1611,7 @@ static struct page *new_page(struct page *p, unsigned long private)
>   * that is not free, and 1 for any other page type.
>   * For 1 the page is returned with increased page count, otherwise not.
>   */
> -static int __get_any_page(struct page *p, unsigned long pfn, int flags)
> +static int __get_any_page(struct page *p, unsigned long pfn)
>  {
>  	int ret;
>  
> @@ -1638,9 +1638,9 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
>  	return ret;
>  }
>  
> -static int get_any_page(struct page *page, unsigned long pfn, int flags)
> +static int get_any_page(struct page *page, unsigned long pfn)
>  {
> -	int ret = __get_any_page(page, pfn, flags);
> +	int ret = __get_any_page(page, pfn);
>  
>  	if (ret == 1 && !PageHuge(page) &&
>  	    !PageLRU(page) && !__PageMovable(page)) {
> @@ -1653,7 +1653,7 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
>  		/*
>  		 * Did it turn free?
>  		 */
> -		ret = __get_any_page(page, pfn, 0);
> +		ret = __get_any_page(page, pfn);
>  		if (ret == 1 && !PageLRU(page)) {
>  			/* Drop page reference which is from __get_any_page() */
>  			put_hwpoison_page(page);
> @@ -1665,7 +1665,7 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
>  	return ret;
>  }
>  
> -static int soft_offline_huge_page(struct page *page, int flags)
> +static int soft_offline_huge_page(struct page *page)
>  {
>  	int ret;
>  	unsigned long pfn = page_to_pfn(page);
> @@ -1724,7 +1724,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  	return ret;
>  }
>  
> -static int __soft_offline_page(struct page *page, int flags)
> +static int __soft_offline_page(struct page *page)
>  {
>  	int ret;
>  	unsigned long pfn = page_to_pfn(page);
> @@ -1804,7 +1804,7 @@ static int __soft_offline_page(struct page *page, int flags)
>  	return ret;
>  }
>  
> -static int soft_offline_in_use_page(struct page *page, int flags)
> +static int soft_offline_in_use_page(struct page *page)
>  {
>  	int ret;
>  	int mt;
> @@ -1834,9 +1834,9 @@ static int soft_offline_in_use_page(struct page *page, int flags)
>  	mt = get_pageblock_migratetype(page);
>  	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>  	if (PageHuge(page))
> -		ret = soft_offline_huge_page(page, flags);
> +		ret = soft_offline_huge_page(page);
>  	else
> -		ret = __soft_offline_page(page, flags);
> +		ret = __soft_offline_page(page);
>  	set_pageblock_migratetype(page, mt);
>  	return ret;
>  }
> @@ -1857,7 +1857,6 @@ static int soft_offline_free_page(struct page *page)
>  /**
>   * soft_offline_page - Soft offline a page.
>   * @page: page to offline
> - * @flags: flags. Same as memory_failure().
>   *
>   * Returns 0 on success, otherwise negated errno.
>   *
> @@ -1876,7 +1875,7 @@ static int soft_offline_free_page(struct page *page)
>   * This is not a 100% solution for all memory, but tries to be
>   * ``good enough'' for the majority of memory.
>   */
> -int soft_offline_page(struct page *page, int flags)
> +int soft_offline_page(struct page *page)
>  {
>  	int ret;
>  	unsigned long pfn = page_to_pfn(page);
> @@ -1893,11 +1892,11 @@ int soft_offline_page(struct page *page, int flags)
>  	}
>  
>  	get_online_mems();
> -	ret = get_any_page(page, pfn, flags);
> +	ret = get_any_page(page, pfn);
>  	put_online_mems();
>  
>  	if (ret > 0)
> -		ret = soft_offline_in_use_page(page, flags);
> +		ret = soft_offline_in_use_page(page);
>  	else if (ret == 0)
>  		ret = soft_offline_free_page(page);
>  
> 

Acked-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

