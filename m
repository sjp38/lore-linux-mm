Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB90FC3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 06:21:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97DD42145D
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 06:21:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="F6TZFAFV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97DD42145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16E7E6B0008; Thu,  5 Sep 2019 02:21:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11DCE6B000A; Thu,  5 Sep 2019 02:21:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0340C6B000C; Thu,  5 Sep 2019 02:21:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id D8CCD6B0008
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 02:21:22 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6688C180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:21:22 +0000 (UTC)
X-FDA: 75899870004.07.foot96_461ae7ce3ba04
X-HE-Tag: foot96_461ae7ce3ba04
X-Filterd-Recvd-Size: 4597
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:21:21 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d70a9620000>; Wed, 04 Sep 2019 23:21:22 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 04 Sep 2019 23:21:19 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 04 Sep 2019 23:21:19 -0700
Received: from [10.2.167.36] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 5 Sep
 2019 06:21:19 +0000
Subject: Re: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka
	<vbabka@suse.cz>
CC: zhong jiang <zhongjiang@huawei.com>, <mhocko@kernel.org>,
	<anshuman.khandual@arm.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Ira Weiny <ira.weiny@intel.com>, Aneesh Kumar
 K.V <aneesh.kumar@linux.vnet.ibm.com>
References: <1567592763-25282-1-git-send-email-zhongjiang@huawei.com>
 <5505fa16-117e-8890-0f48-38555a61a036@suse.cz>
 <20190904114820.42d9c4daf445ded3d0da52ab@linux-foundation.org>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <73c49a1b-4f42-c21d-ccd8-2b063cdf1293@nvidia.com>
Date: Wed, 4 Sep 2019 23:19:13 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.0
MIME-Version: 1.0
In-Reply-To: <20190904114820.42d9c4daf445ded3d0da52ab@linux-foundation.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1567664482; bh=DzFa+CDkOTbrnmZhWcz0uP3s2EDeVid5LGISje7+G1U=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=F6TZFAFVjn15UQhmjziVYXOLPIcXaeztI6o6Hxs10SRR/6d+HgYPBq5jQjX+KYnPp
	 1FKRExG8FFgJm/nbVPUiS+0rENGKhnZw/u0t3iiRhJRSuVLHrJlUDVwUhurgzSVtWN
	 ELW2zfdnankNguVV8+HkMWcYDpBefCAXLntSKsqtFxKKj1/mjryqVsP442RjljUl6p
	 Af3TArq2OLxiPVVjtQNuQ/z6+iTveWQB2MzB7hZ2tbqZeRzAMOnUnaEV4roT4fQxxT
	 AjvUmvBLiGGqkOVgq038d4/K/a2txJwj+uT4/dkMHK+bJzg8p7eM26xDgJs4X6P7Je
	 cbqi9nvBIhy+w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/4/19 11:48 AM, Andrew Morton wrote:
> On Wed, 4 Sep 2019 13:24:58 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> On 9/4/19 12:26 PM, zhong jiang wrote:
>>> With the help of unsigned_lesser_than_zero.cocci. Unsigned 'nr_pages"'
>>> compare with zero. And __get_user_pages_locked will return an long value.
>>> Hence, Convert the long to compare with zero is feasible.
>>
>> It would be nicer if the parameter nr_pages was long again instead of unsigned
>> long (note there are two variants of the function, so both should be changed).
> 
> nr_pages should be unsigned - it's a count of pages!
> 

Yes!

> The bug is that __get_user_pages_locked() returns a signed long which
> can be a -ve errno.
> 
> I think it's best if __get_user_pages_locked() is to get itself a new
> local with the same type as its return value.  Something like:
> 
> --- a/mm/gup.c~a
> +++ a/mm/gup.c
> @@ -1450,6 +1450,7 @@ static long check_and_migrate_cma_pages(
>   	bool drain_allow = true;
>   	bool migrate_allow = true;
>   	LIST_HEAD(cma_page_list);
> +	long ret;
>   
>   check_again:
>   	for (i = 0; i < nr_pages;) {
> @@ -1511,17 +1512,18 @@ check_again:
>   		 * again migrating any new CMA pages which we failed to isolate
>   		 * earlier.
>   		 */
> -		nr_pages = __get_user_pages_locked(tsk, mm, start, nr_pages,
> +		ret = __get_user_pages_locked(tsk, mm, start, nr_pages,
>   						   pages, vmas, NULL,
>   						   gup_flags);
>   
> -		if ((nr_pages > 0) && migrate_allow) {
> +		nr_pages = ret;
> +		if (ret > 0 && migrate_allow) {
>   			drain_allow = true;
>   			goto check_again;
>   		}
>   	}
>   
> -	return nr_pages;
> +	return ret;
>   }
>   #else
>   static long check_and_migrate_cma_pages(struct task_struct *tsk,
> 

+1 for this approach, please.


thanks,
-- 
John Hubbard
NVIDIA
  

