Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC0E5C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 385DB21473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:14:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="JDzuRnnE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 385DB21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2C738E0002; Wed, 30 Jan 2019 02:14:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDE1A8E0001; Wed, 30 Jan 2019 02:14:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACC9B8E0002; Wed, 30 Jan 2019 02:14:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F74F8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:14:20 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id y4so4465955ybi.0
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 23:14:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=IvL16ivhdsIxfTZ+U9szh7teG9PO5njDgExBoW8AbhM=;
        b=gixw4NMdhODZkisxlRjm3zBUbv7azyRJxBBxgmkRlnj4JinFEL5m48RwI5a0qBPklQ
         9pAbI/YKI9Nv0Ldrn5GTpKVKGuhUVnaP/NAsunQ6e+dmaMWz2/+5fPD1Os9gYmfygEzg
         mlVHcEMdRSTTC7bRXLSc7yupdHNGQgRTTi3X/AVr6D+MPGXdFKUbGIJWjNY0euQXal1r
         2adveUeqJSyz1yuibnI2kJGT7iNOPKqNuSlBJ8KXUvRgByIq2u3QQDRs+adBtd6AHclk
         oC0lL4qzrYVOjK5gYe8flMDak13vTrgBAdynJ3jmUKgYIx4Jbrz2Kv99brIRXQD8M7pt
         thOw==
X-Gm-Message-State: AJcUukfmzsiyhburpInqZIxYCy5dDG/z5KddJS4Jsd0rmc6iTOBFi8V1
	fMGflB1WS2NTv49H/YmjF+h0k0f3s/FHmLcEKBSRYufp5d3mv81ndMN+lIj2l3+e7COmUNViBWY
	0442/qgTKHtwG5i3et2bz+zJO+uC7BUkjTliSIumiAaPZY3ORnfmYY94Yi5IdiMAKaA==
X-Received: by 2002:a25:a1a3:: with SMTP id a32mr27394947ybi.296.1548832460140;
        Tue, 29 Jan 2019 23:14:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN69lN+ytvVqHDYyGilx38By6p7orB9e6hs1CW2fi5TW2S0D0320CjHsVnS5oCou5GZranSi
X-Received: by 2002:a25:a1a3:: with SMTP id a32mr27394908ybi.296.1548832459146;
        Tue, 29 Jan 2019 23:14:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548832459; cv=none;
        d=google.com; s=arc-20160816;
        b=V9pva2/6mzOWZZJGEjlqz5XbPtzNZh8QlT9kdVITfoLzKR2yW/lgswpj11+IL8pS33
         Y+wLFwCGC1ezpcC4QqkZCMem7L1tkveW7neJE2CQLMpRsuDh0imJVAb5bhPzsOnReIKv
         j/xO7DEOkacbb3Dna08mrn/SbBfDLVXZGFJVpuyrhOCVf/+1PXnIbqsfFH5uttZuXpN2
         1E0slXzA5aNnZF1pl5OkOjCmMGk0UH+fi4H0PpenmIvplMQEog6OWrnWQEYKSVyuELee
         hEZjlAorDKl/zxZZ0DGcIhbGNFEADTkJJxMhqXXw41ns0cf2arc0kPLPHKRlWwf9/MOP
         Dr9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=IvL16ivhdsIxfTZ+U9szh7teG9PO5njDgExBoW8AbhM=;
        b=LsfWXmLGgLhnk4LdkM4I5wr+5vVTEfjsiTuMnPUwTrAtk5BDvP3dhfOuX7rHOF8nB1
         OjqZ0WjpNhndoatidlUBgbA+66gseMcRdggCmQfoOKW+OxOwPxb1BHeXnoQI3lMDU28t
         0AKOdjuRH+mn7UhWY9Qg4xSmpo9HPfzLQ9IoSf5/oD7+CkY9Bq9DyE1P5nlrSelkI001
         iA7FNf1aqwNPhepJhL41ic4gXtT+uD7Ydnnow/wDcF4ej/dvQZs5ik2VnNhrEe0xQeHS
         EZrIV5tNLkOOaHnMHre5eT+GhWiVCPU+I6JSXTolEbn5KzIsEnUcloq/jzTlBO0nBnNV
         nLUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=JDzuRnnE;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id r131si389778yba.164.2019.01.29.23.14.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 23:14:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=JDzuRnnE;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c514eae0001>; Tue, 29 Jan 2019 23:13:50 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 29 Jan 2019 23:14:18 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 29 Jan 2019 23:14:18 -0800
Received: from [10.2.167.94] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 30 Jan
 2019 07:14:17 +0000
Subject: Re: [v3 PATCH] mm: ksm: do not block on page lock when searching
 stable tree
To: Yang Shi <yang.shi@linux.alibaba.com>, <ktkhai@virtuozzo.com>,
	<hughd@google.com>, <aarcange@redhat.com>, <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
References: <1548793753-62377-1-git-send-email-yang.shi@linux.alibaba.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <82ba1395-baab-3b95-a3f7-47e219551881@nvidia.com>
Date: Tue, 29 Jan 2019 23:14:19 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1548793753-62377-1-git-send-email-yang.shi@linux.alibaba.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1548832430; bh=IvL16ivhdsIxfTZ+U9szh7teG9PO5njDgExBoW8AbhM=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=JDzuRnnENnsvAh+uHtHJHlz/aSTRnpkyE6yf6vsigRnMJaxhKvlrtwNnNz5ar++yK
	 jrS07PI4tZPzUZg/4VvsZZCyXIVZwT0INcBwC6bw5QLCHRYhvjty/WCIYCMQ2kq1wZ
	 vP+LL896zkZUnPfrkWa8PjfizWD6g6HybAxuFs2JvD/QuRS7VoyNF8V0WiKywibiid
	 2QV/tZL7fgd5G+114or5YRM39BY8cn91FQJF6Gkl1VWtiSqx8+996Jsbp1S1bN4o2N
	 VFE7t7Ai6AUGU+Z/+86rTGNFeOwloYRaPVh3tDMV1wAjqIdwjgyIoO/tx6ihIAVt2t
	 S2SS2R00Q0hVQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/29/19 12:29 PM, Yang Shi wrote:
> ksmd need search stable tree to look for the suitable KSM page, but the
> KSM page might be locked for a while due to i.e. KSM page rmap walk.
> Basically it is not a big deal since commit 2c653d0ee2ae
> ("ksm: introduce ksm_max_page_sharing per page deduplication limit"),
> since max_page_sharing limits the number of shared KSM pages.
> 
> But it still sounds not worth waiting for the lock, the page can be skip,
> then try to merge it in the next scan to avoid potential stall if its
> content is still intact.
> 
> Introduce trylock mode to get_ksm_page() to not block on page lock, like
> what try_to_merge_one_page() does.  And, define three possible
> operations (nolock, lock and trylock) as enum type to avoid stacking up
> bools and make the code more readable.
> 
> Return -EBUSY if trylock fails, since NULL means not find suitable KSM
> page, which is a valid case.
> 
> With the default max_page_sharing setting (256), there is almost no
> observed change comparing lock vs trylock.
> 
> However, with ksm02 of LTP, the reduced ksmd full scan time can be
> observed, which has set max_page_sharing to 786432.  With lock version,
> ksmd may tak 10s - 11s to run two full scans, with trylock version ksmd
> may take 8s - 11s to run two full scans.  And, the number of
> pages_sharing and pages_to_scan keep same.  Basically, this change has
> no harm >
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Suggested-by: John Hubbard <jhubbard@nvidia.com>
> Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> Hi folks,
> 
> This patch was with "mm: vmscan: skip KSM page in direct reclaim if priority
> is low" in the initial submission.  Then Hugh and Andrea pointed out commit
> 2c653d0ee2ae ("ksm: introduce ksm_max_page_sharing per page deduplication
> limit") is good enough for limiting the number of shared KSM page to prevent
> from softlock when walking ksm page rmap.  This commit does solve the problem.
> So, the series was dropped by Andrew from -mm tree.
> 
> However, I thought the second patch (this one) still sounds useful.  So, I did
> some test and resubmit it.  The first version was reviewed by Krill Tkhai, so
> I keep his Reviewed-by tag since there is no change to the patch except the
> commit log.
> 
> So, would you please reconsider this patch?
> 
> v3: Use enum to define get_ksm_page operations (nolock, lock and trylock) per
>      John Hubbard
> v2: Updated the commit log to reflect some test result and latest discussion
> 
>   mm/ksm.c | 46 ++++++++++++++++++++++++++++++++++++----------
>   1 file changed, 36 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 6c48ad1..5647bc1 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -667,6 +667,12 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>   	free_stable_node(stable_node);
>   }
>   
> +enum get_ksm_page_flags {
> +	GET_KSM_PAGE_NOLOCK,
> +	GET_KSM_PAGE_LOCK,
> +	GET_KSM_PAGE_TRYLOCK
> +};
> +
>   /*
>    * get_ksm_page: checks if the page indicated by the stable node
>    * is still its ksm page, despite having held no reference to it.
> @@ -686,7 +692,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>    * a page to put something that might look like our key in page->mapping.
>    * is on its way to being freed; but it is an anomaly to bear in mind.
>    */
> -static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
> +static struct page *get_ksm_page(struct stable_node *stable_node,
> +				 enum get_ksm_page_flags flags)
>   {
>   	struct page *page;
>   	void *expected_mapping;
> @@ -728,8 +735,15 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>   		goto stale;
>   	}
>   
> -	if (lock_it) {
> +	if (flags == GET_KSM_PAGE_TRYLOCK) {
> +		if (!trylock_page(page)) {
> +			put_page(page);
> +			return ERR_PTR(-EBUSY);
> +		}
> +	} else if (flags == GET_KSM_PAGE_LOCK)
>   		lock_page(page);
> +
> +	if (flags != GET_KSM_PAGE_NOLOCK) {
>   		if (READ_ONCE(page->mapping) != expected_mapping) {
>   			unlock_page(page);
>   			put_page(page);
> @@ -763,7 +777,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
>   		struct page *page;
>   
>   		stable_node = rmap_item->head;
> -		page = get_ksm_page(stable_node, true);
> +		page = get_ksm_page(stable_node, GET_KSM_PAGE_LOCK);
>   		if (!page)
>   			goto out;
>   
> @@ -863,7 +877,7 @@ static int remove_stable_node(struct stable_node *stable_node)
>   	struct page *page;
>   	int err;
>   
> -	page = get_ksm_page(stable_node, true);
> +	page = get_ksm_page(stable_node, GET_KSM_PAGE_LOCK);
>   	if (!page) {
>   		/*
>   		 * get_ksm_page did remove_node_from_stable_tree itself.
> @@ -1385,7 +1399,7 @@ static struct page *stable_node_dup(struct stable_node **_stable_node_dup,
>   		 * stable_node parameter itself will be freed from
>   		 * under us if it returns NULL.
>   		 */
> -		_tree_page = get_ksm_page(dup, false);
> +		_tree_page = get_ksm_page(dup, GET_KSM_PAGE_NOLOCK);
>   		if (!_tree_page)
>   			continue;
>   		nr += 1;
> @@ -1508,7 +1522,7 @@ static struct page *__stable_node_chain(struct stable_node **_stable_node_dup,
>   	if (!is_stable_node_chain(stable_node)) {
>   		if (is_page_sharing_candidate(stable_node)) {
>   			*_stable_node_dup = stable_node;
> -			return get_ksm_page(stable_node, false);
> +			return get_ksm_page(stable_node, GET_KSM_PAGE_NOLOCK);
>   		}
>   		/*
>   		 * _stable_node_dup set to NULL means the stable_node
> @@ -1613,7 +1627,8 @@ static struct page *stable_tree_search(struct page *page)
>   			 * wrprotected at all times. Any will work
>   			 * fine to continue the walk.
>   			 */
> -			tree_page = get_ksm_page(stable_node_any, false);
> +			tree_page = get_ksm_page(stable_node_any,
> +						 GET_KSM_PAGE_NOLOCK);
>   		}
>   		VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
>   		if (!tree_page) {
> @@ -1673,7 +1688,12 @@ static struct page *stable_tree_search(struct page *page)
>   			 * It would be more elegant to return stable_node
>   			 * than kpage, but that involves more changes.
>   			 */
> -			tree_page = get_ksm_page(stable_node_dup, true);
> +			tree_page = get_ksm_page(stable_node_dup,
> +						 GET_KSM_PAGE_TRYLOCK);
> +
> +			if (PTR_ERR(tree_page) == -EBUSY)
> +				return ERR_PTR(-EBUSY);

or just:

	if (PTR_ERR(tree_page) == -EBUSY)
		return tree_page;

right?

> +
>   			if (unlikely(!tree_page))
>   				/*
>   				 * The tree may have been rebalanced,
> @@ -1842,7 +1862,8 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>   			 * wrprotected at all times. Any will work
>   			 * fine to continue the walk.
>   			 */
> -			tree_page = get_ksm_page(stable_node_any, false);
> +			tree_page = get_ksm_page(stable_node_any,
> +						 GET_KSM_PAGE_NOLOCK);
>   		}
>   		VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
>   		if (!tree_page) {
> @@ -2060,6 +2081,10 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>   
>   	/* We first start with searching the page inside the stable tree */
>   	kpage = stable_tree_search(page);
> +
> +	if (PTR_ERR(kpage) == -EBUSY)
> +		return;
> +
>   	if (kpage == page && rmap_item->head == stable_node) {
>   		put_page(kpage);
>   		return;
> @@ -2242,7 +2267,8 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>   
>   			list_for_each_entry_safe(stable_node, next,
>   						 &migrate_nodes, list) {
> -				page = get_ksm_page(stable_node, false);
> +				page = get_ksm_page(stable_node,
> +						    GET_KSM_PAGE_NOLOCK);
>   				if (page)
>   					put_page(page);
>   				cond_resched();
> 

Hi Yang,

The patch looks correct as far doing what it claims to do. I'll leave it
to others to decide if a trylock-based approach is really what you want,
for KSM scans. It seems reasonable from my very limited knowledge of
KSM: there shouldn't be any cases where you really *need* to wait for
a page lock, because the whole system is really sort of an optimization
anyway.


thanks,
-- 
John Hubbard
NVIDIA

