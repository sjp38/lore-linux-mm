Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9D06C282DE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:15:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6110620863
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:15:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="UlCyETzz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6110620863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03C4A6B029D; Thu, 23 May 2019 15:15:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F07E16B029E; Thu, 23 May 2019 15:15:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D81496B02A1; Thu, 23 May 2019 15:15:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id B50ED6B029D
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:15:00 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id h83so6108977ybh.15
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:15:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=UY9XbZfKozlXpv9o2aoFRaWDQi9QopjyohU9JWXzpVU=;
        b=PFi/qwlqi0VpCXYKrfYQFk5QzkWWDzg667PEGBfNtfdmPYhuFRrUUWOEIEwuqMQtt2
         X+Aqseu8HPAawqLvXp+4XuHtRE1TDaZGXaXiA9EOb81dSxq4l/KxXOXokellltP9LV7H
         DPnqzhGd11o77lL89blkIbN6/3Xt91oC8Y6hz4kbM6M62SxAYTZ81Q0elBVaS7FcB7Fh
         loI1kbqyutEV8Ko6p1woSIEdK26jzxTvZdtRQhZnaJz4eZW+OMwBB61XcInd6HvsCwRy
         5713q+4pKPRfFObZw/q/3AxbyA7KQRQ7gouc7imb+hYEQtHblmhzjeVHvVw4cqNI/kPI
         KaKw==
X-Gm-Message-State: APjAAAVdmLycvj3bSyKvSsqfHMSSh7rzBqNlDO/y/zuVy8Im24GXGfvJ
	RA5PKNye7ZqtjLaNKTst83UoRr81aNlauT4tvXTO8Es+/uCnuKRslI6kSwsqGuJI/7DZOBSxjPz
	0G9i1d8Q+N4R49o9TYIPN/WM25WxPdPcftSBww8x4zmjuQgXhau/tadhOfn/gexO2tA==
X-Received: by 2002:a25:cc02:: with SMTP id l2mr20617390ybf.107.1558638900505;
        Thu, 23 May 2019 12:15:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzQu945oHgTdcmRrnZbVniQ6xjpv5o0eN8e91H408Ctopnv6hYogOl+A451Pss9Nn9xkHq
X-Received: by 2002:a25:cc02:: with SMTP id l2mr20617335ybf.107.1558638899325;
        Thu, 23 May 2019 12:14:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558638899; cv=none;
        d=google.com; s=arc-20160816;
        b=TrozZFXM3s/UjbfWCHqbjEKsccrBvxDIKaTXoxw78q0cHKgS+jNVJueO5kdfBzYx4/
         vQ2QjQ1TJTtOyhELkcuwaH3gU6uNOBwXR/Qw/clt0Kz61BFdEekbs6YRkIQnVCD6VyzM
         lcP3cusNU0V+S6/CJsw1ggB6QXJ/gTYhyzNu13B5dRyphKhvxtLdeA4gS+YNqjd2GDVK
         VZN5p70/1/vtwUqrGfGnofvbTfyLBDWer2LphgAt6pO5Ecy9wJ5Xp4I7pJg/7pyhz9gc
         Q79EsFnrdeJYLxxinekTHJ2AMvvmW2w24bEREAz6eNUUchm/RU31jgFT2CF6n/An3x+K
         t0VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=UY9XbZfKozlXpv9o2aoFRaWDQi9QopjyohU9JWXzpVU=;
        b=PLvIKgUjgKfgaZgD1MCJ1LGIS3IafKrEJ+RF9ndMKai6dZy34lkIjNSsuZmKgH2vhg
         dHrejlVZcK9qENZoRKC+VmJbWxKloh+N3kPn4ntS6sZDKyXsh+2x7kMMWFA32EWIuIps
         zlNm1vgcVAzBZKrb99c2ZUZHYGdXPlIS090bqcM67ra+hynd7th+opIBKG6MEqbPzF/W
         i6i+k4QSleE0XK8UHJhUgWP7233WYmR56JRK3vriiSdKFPYAfBsoWP/Bs4936TSCX7C8
         gjMoPJEjftXc6vMX05Pv7RWxkFPi+UvMJbjccP9yiSgEwkBfzjwUJZwZwYCY0gaXt1wM
         9ooQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=UlCyETzz;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 205si35177ybz.335.2019.05.23.12.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 12:14:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=UlCyETzz;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce6f1330000>; Thu, 23 May 2019 12:14:59 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 23 May 2019 12:14:58 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 23 May 2019 12:14:58 -0700
Received: from [10.2.169.219] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 23 May
 2019 19:14:55 +0000
Subject: Re: [PATCH 1/1] infiniband/mm: convert put_page() to put_user_page*()
To: Ira Weiny <ira.weiny@intel.com>
CC: Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton
	<akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, Doug Ledford <dledford@redhat.com>, "Mike
 Marciniszyn" <mike.marciniszyn@intel.com>, Dennis Dalessandro
	<dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, "Jan
 Kara" <jack@suse.cz>
References: <20190523072537.31940-1-jhubbard@nvidia.com>
 <20190523072537.31940-2-jhubbard@nvidia.com>
 <20190523172852.GA27175@iweiny-DESK2.sc.intel.com>
 <20190523173222.GH12145@mellanox.com>
 <fa6d7d7c-13a3-0586-6384-768ebb7f0561@nvidia.com>
 <20190523190423.GA19578@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <0bd9859f-8eb0-9148-6209-08ae42665626@nvidia.com>
Date: Thu, 23 May 2019 12:13:59 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190523190423.GA19578@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558638899; bh=UY9XbZfKozlXpv9o2aoFRaWDQi9QopjyohU9JWXzpVU=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=UlCyETzzaQ69ETX9skUfRlp0Ws2f09G7a7Bo59JXjJY1SksQCN3vi04EoWKN1tvVl
	 PAfg85V2edI4mXiPrL8gXtNMDIGUxlnfsB/Y5Gt1KIPk93HEXlTyxEe74zL6C83bay
	 lKplan6XSz4t9SXkpPiusZV0sHa3T3DIyhLKSsi+X1N7GPOxl6CA9cinVOQIc/Jjgi
	 va00dxw7OuhfxA3TRaC8QAT0LuO8Ar1NeyHIkLL9V+4EjyelkCa6anmoR+UnQKynzv
	 qVyaad9/48fczyD2gljFaUj7ZPCfUErO+gd5Rzw+pEJKWjJRMSotrrnRsb9C0s497M
	 FCPLVt3uXeQUQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/23/19 12:04 PM, Ira Weiny wrote:
> On Thu, May 23, 2019 at 10:46:38AM -0700, John Hubbard wrote:
>> On 5/23/19 10:32 AM, Jason Gunthorpe wrote:
>>> On Thu, May 23, 2019 at 10:28:52AM -0700, Ira Weiny wrote:
>>>>> @@ -686,8 +686,8 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
>>>>>    			 * ib_umem_odp_map_dma_single_page().
>>>>>    			 */
>>>>>    			if (npages - (j + 1) > 0)
>>>>> -				release_pages(&local_page_list[j+1],
>>>>> -					      npages - (j + 1));
>>>>> +				put_user_pages(&local_page_list[j+1],
>>>>> +					       npages - (j + 1));
>>>>
>>>> I don't know if we discussed this before but it looks like the use of
>>>> release_pages() was not entirely correct (or at least not necessary) here.  So
>>>> I think this is ok.
>>>
>>> Oh? John switched it from a put_pages loop to release_pages() here:
>>>
>>> commit 75a3e6a3c129cddcc683538d8702c6ef998ec589
>>> Author: John Hubbard <jhubbard@nvidia.com>
>>> Date:   Mon Mar 4 11:46:45 2019 -0800
>>>
>>>       RDMA/umem: minor bug fix in error handling path
>>>       1. Bug fix: fix an off by one error in the code that cleans up if it fails
>>>          to dma-map a page, after having done a get_user_pages_remote() on a
>>>          range of pages.
>>>       2. Refinement: for that same cleanup code, release_pages() is better than
>>>          put_page() in a loop.
>>>
>>> And now we are going to back something called put_pages() that
>>> implements the same for loop the above removed?
>>>
>>> Seems like we are going in circles?? John?
>>>
>>
>> put_user_pages() is meant to be a drop-in replacement for release_pages(),
>> so I made the above change as an interim step in moving the callsite from
>> a loop, to a single call.
>>
>> And at some point, it may be possible to find a way to optimize put_user_pages()
>> in a similar way to the batching that release_pages() does, that was part
>> of the plan for this.
>>
>> But I do see what you mean: in the interim, maybe put_user_pages() should
>> just be calling release_pages(), how does that change sound?
> 
> I'm certainly not the expert here but FWICT release_pages() was originally
> designed to work with the page cache.
> 
> aabfb57296e3  mm: memcontrol: do not kill uncharge batching in free_pages_and_swap_cache
> 
> But at some point it was changed to be more general?
> 
> ea1754a08476 mm, fs: remove remaining PAGE_CACHE_* and page_cache_{get,release} usage
> 
> ... and it is exported and used outside of the swapping code... and used at
> lease 1 place to directly "put" pages gotten from get_user_pages_fast()
> [arch/x86/kvm/svm.c]
> 
>  From that it seems like it is safe.
> 
> But I don't see where release_page() actually calls put_page() anywhere?  What
> am I missing?
> 

For that question, I recall having to look closely at this function, as well:

void release_pages(struct page **pages, int nr)
{
	int i;
	LIST_HEAD(pages_to_free);
	struct pglist_data *locked_pgdat = NULL;
	struct lruvec *lruvec;
	unsigned long uninitialized_var(flags);
	unsigned int uninitialized_var(lock_batch);

	for (i = 0; i < nr; i++) {
		struct page *page = pages[i];

		/*
		 * Make sure the IRQ-safe lock-holding time does not get
		 * excessive with a continuous string of pages from the
		 * same pgdat. The lock is held only if pgdat != NULL.
		 */
		if (locked_pgdat && ++lock_batch == SWAP_CLUSTER_MAX) {
			spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
			locked_pgdat = NULL;
		}

		if (is_huge_zero_page(page))
			continue;

		/* Device public page can not be huge page */
		if (is_device_public_page(page)) {
			if (locked_pgdat) {
				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
						       flags);
				locked_pgdat = NULL;
			}
			put_devmap_managed_page(page);
			continue;
		}

		page = compound_head(page);
		if (!put_page_testzero(page))

		     ^here is where it does the put_page() call, is that what
			you were looking for?



thanks,
-- 
John Hubbard
NVIDIA

