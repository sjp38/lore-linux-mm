Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B8EFECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 10:24:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CAE52082C
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 10:24:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CAE52082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9EEB6B0006; Wed, 11 Sep 2019 06:24:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E516E6B0007; Wed, 11 Sep 2019 06:24:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D182B6B0008; Wed, 11 Sep 2019 06:24:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id AFAAD6B0006
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 06:24:14 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 5EA9E6D64
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:24:14 +0000 (UTC)
X-FDA: 75922254828.25.coat63_420316f6a3d4d
X-HE-Tag: coat63_420316f6a3d4d
X-Filterd-Recvd-Size: 8153
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:24:13 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8C5DE898102;
	Wed, 11 Sep 2019 10:24:12 +0000 (UTC)
Received: from [10.36.117.155] (ovpn-117-155.ams2.redhat.com [10.36.117.155])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2DD3F60BEC;
	Wed, 11 Sep 2019 10:24:11 +0000 (UTC)
Subject: Re: [PATCH 04/10] mm,hwpoison: remove MF_COUNT_INCREASED
To: Oscar Salvador <osalvador@suse.de>, n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190910103016.14290-1-osalvador@suse.de>
 <20190910103016.14290-5-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <850f227f-8448-5dfa-59c3-87de4f157551@redhat.com>
Date: Wed, 11 Sep 2019 12:24:10 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190910103016.14290-5-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.67]); Wed, 11 Sep 2019 10:24:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.09.19 12:30, Oscar Salvador wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Now there's no user of MF_COUNT_INCREASED, so we can safely remove
> it from all calling points.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  include/linux/mm.h  |  7 +++----
>  mm/memory-failure.c | 16 +++-------------
>  2 files changed, 6 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ad6766a08f9b..fb36a4165a4e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2814,10 +2814,9 @@ void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
>  				  unsigned long nr_pages);
>  
>  enum mf_flags {
> -	MF_COUNT_INCREASED = 1 << 0,
> -	MF_ACTION_REQUIRED = 1 << 1,
> -	MF_MUST_KILL = 1 << 2,
> -	MF_SOFT_OFFLINE = 1 << 3,
> +	MF_ACTION_REQUIRED = 1 << 0,
> +	MF_MUST_KILL = 1 << 1,
> +	MF_SOFT_OFFLINE = 1 << 2,
>  };
>  extern int memory_failure(unsigned long pfn, int flags);
>  extern void memory_failure_queue(unsigned long pfn, int flags);
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index e43b61462fd5..1be785b25324 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1092,7 +1092,7 @@ static int memory_failure_hugetlb(unsigned long pfn, int flags)
>  
>  	num_poisoned_pages_inc();
>  
> -	if (!(flags & MF_COUNT_INCREASED) && !get_hwpoison_page(p)) {
> +	if (!get_hwpoison_page(p)) {
>  		/*
>  		 * Check "filter hit" and "race with other subpage."
>  		 */
> @@ -1286,7 +1286,7 @@ int memory_failure(unsigned long pfn, int flags)
>  	 * In fact it's dangerous to directly bump up page count from 0,
>  	 * that may make page_ref_freeze()/page_ref_unfreeze() mismatch.
>  	 */
> -	if (!(flags & MF_COUNT_INCREASED) && !get_hwpoison_page(p)) {
> +	if (!get_hwpoison_page(p)) {
>  		if (is_free_buddy_page(p)) {
>  			action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
>  			return 0;
> @@ -1327,10 +1327,7 @@ int memory_failure(unsigned long pfn, int flags)
>  	shake_page(p, 0);
>  	/* shake_page could have turned it free. */
>  	if (!PageLRU(p) && is_free_buddy_page(p)) {
> -		if (flags & MF_COUNT_INCREASED)
> -			action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
> -		else
> -			action_result(pfn, MF_MSG_BUDDY_2ND, MF_DELAYED);
> +		action_result(pfn, MF_MSG_BUDDY_2ND, MF_DELAYED);
>  		return 0;
>  	}
>  
> @@ -1618,9 +1615,6 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
>  {
>  	int ret;
>  
> -	if (flags & MF_COUNT_INCREASED)
> -		return 1;
> -
>  	/*
>  	 * When the target page is a free hugepage, just remove it
>  	 * from free hugepage list.
> @@ -1890,15 +1884,11 @@ int soft_offline_page(struct page *page, int flags)
>  	if (is_zone_device_page(page)) {
>  		pr_debug_ratelimited("soft_offline: %#lx page is device page\n",
>  				pfn);
> -		if (flags & MF_COUNT_INCREASED)
> -			put_page(page);
>  		return -EIO;
>  	}
>  
>  	if (PageHWPoison(page)) {
>  		pr_info("soft offline: %#lx page already poisoned\n", pfn);
> -		if (flags & MF_COUNT_INCREASED)
> -			put_hwpoison_page(page);
>  		return -EBUSY;
>  	}
>  
> 

Acked-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

