Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0041C46470
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 22:50:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9064A2177E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 22:50:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="PL1hqSFG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9064A2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A7556B0003; Thu, 23 May 2019 18:50:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27EA26B0005; Thu, 23 May 2019 18:50:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 195546B0006; Thu, 23 May 2019 18:50:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEEC66B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 18:50:21 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j72so2548557ywa.5
        for <linux-mm@kvack.org>; Thu, 23 May 2019 15:50:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=pnD2mPom1537ot4zdnaJYiSqU3krtz3ITZMHoUjrO54=;
        b=hOkaP+KvhNjQc1RpFjRs/YbeMKRbD11CvKLZR+EXPB9k4N0d9/6LZhXcA4Eoj9xNtg
         jG7nEEiRxqYcNf8LOhHe5uksCy9TE2zyU6BZ/EdVki2c4/shjSGSxWCCDV9qgjsmWl2U
         u+e3QZaG9Ntt/k+ejTfD5SfDNir0g+rL6vXhgLDs1WKfokvB0s8xamduCIItbUH2yiEd
         0cCYvPS7XyuoEnxa+wBf6Baqk6YOtnKSVqdH87UKnXdVkmZw9tSsM7wlPGqJ1PlQsQqM
         8nD6VmXOt+PA9AzljFpOugOxfesBjPlY4qosRHcwLOIDKxaQL2VMcO9P1wBSwnQG7+cA
         Qxqg==
X-Gm-Message-State: APjAAAXwSpCJUS4DWRaLzSSpmUn9UMAOJisxfzJFC6AJmf+ebPLnU383
	DqrglOme0it26Cdqz8MwQHbjRKG1UTrlfd6H+dgTZ6ISCNn8AyBR0RTuTAYM/cIRKFavAcCvqBI
	0h96nxBF7Ho5/bXGekmTFlVg45J8ufLOV3yFeB68z/CDAiuya0jWG64SRp3crMTrYug==
X-Received: by 2002:a81:4f06:: with SMTP id d6mr32488954ywb.379.1558651821686;
        Thu, 23 May 2019 15:50:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXLYelSFfucB3R6mThUHiFmAR9yYyd0G3rHUonO+MSbIRQMMXLeuSvtrGrT3PrYlD8yYD6
X-Received: by 2002:a81:4f06:: with SMTP id d6mr32488938ywb.379.1558651821024;
        Thu, 23 May 2019 15:50:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558651821; cv=none;
        d=google.com; s=arc-20160816;
        b=Ti1M/n/G/WLuteLRZ59JptrYKUZD7fKUcqTs0M8I1jaZO2WAiB3AQrKqrwF4dCHnWo
         j2nc1SznsofjUrl4A2NUb4pltOKmfsTSWGXwzzfHbJl9o5yhRRUHKYhTL1RRHdO5nclD
         Z3k3+eMM8wNnLURAziANKCGR6tyBkI+T8lWLJUyiv5AU2L/RTwe2s/eJUFqMnKhnSLvB
         NpwGBIn3prsKlu77ZE10tGNB4w8nAE/bK2EqYGg1RKrp9vgSFQi15erFtiDgwtdeyLlj
         pUuvZzn1NUWMNQI8F9E1tYMv47eTF6EQ6RDnY3eevEfDOe5PMZ6l5jquDC3AVyh0DuFP
         3DjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=pnD2mPom1537ot4zdnaJYiSqU3krtz3ITZMHoUjrO54=;
        b=rNjW7G/iII9gGL+hh/zx6A1leXYQOHZKo6jLc/S6XyGLZRM/Q+A643boa2x/UoCVwi
         DWMWgpVKTixWSKKcoOpmXhWTqqOYvyzn7V17oNP7AOdfgAzQyAzO0ULF7by60+QdT2dc
         lCDNxrObL89ByGa/ilXddfguzL8dqBzBqaVb9xSzI+8EeGWoj5HoSJ60LlwBh2fuyms1
         /qIge5Y3YdVQIzXKZMP6yX1tAvZA8jOXROqPbjBtcfPB+ZgLl77f81RUxHCXSm48mT5e
         WL+qVQVorX4gwZd16PyIepwBoPHmzxakl9rcOnjsScUy4tTaTlnkA+NOeiYw1eztaJ4n
         pmuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=PL1hqSFG;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id f6si209962ybb.304.2019.05.23.15.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 15:50:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=PL1hqSFG;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce723ac0005>; Thu, 23 May 2019 15:50:20 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 23 May 2019 15:50:19 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 23 May 2019 15:50:19 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 23 May
 2019 22:50:14 +0000
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
 <0bd9859f-8eb0-9148-6209-08ae42665626@nvidia.com>
 <20190523223701.GA15048@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <050f56d0-1dda-036e-e508-3a7255ac7b59@nvidia.com>
Date: Thu, 23 May 2019 15:50:14 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190523223701.GA15048@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558651820; bh=pnD2mPom1537ot4zdnaJYiSqU3krtz3ITZMHoUjrO54=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=PL1hqSFGAyha/HZ79WcNqF63aQObWkwaPlneBIGP0b7M7mgvTnxDuamjPTAyGfKF1
	 yHMeLk26WEhfP2v931D1xU4W3M3kiwYQmBfLraEzR5YZXcfsobgtoJPyyLH4+6FTSu
	 jnQhcgabwqiWxG7558a5TO0DHh6plvrU70wZ6snBovpECiJdOYn4l86CCwmo3NDu3O
	 3UXNZap6nUALoyxA2W+ylo2ndYIsR8f9oF+z0OhfOamlbdOLOBUEnQFBZGiQWt1HUc
	 6E7eSVdsS34aUe5ZN9gIcZVR9Y/B0Sxsb590oa3FJ9NZuUjjM8XRY+0vmapyQQB2fM
	 PPK57wDeZu70A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/23/19 3:37 PM, Ira Weiny wrote:
[...] 
> I've dug in further and I see now that release_pages() implements (almost the
> same thing, see below) as put_page().
> 
> However, I think we need to be careful here because put_page_testzero() calls
> 
> 	page_ref_dec_and_test(page);
> 
> ... and after your changes it will need to call ...
> 
> 	page_ref_sub_return(page, GUP_PIN_COUNTING_BIAS);
> 
> ... on a GUP page:
> 
> So how do you propose calling release_pages() from within put_user_pages()?  Or
> were you thinking this would be temporary?

I was thinking of it as a temporary measure, only up until, but not including the
point where put_user_pages() becomes active. That is, the point when put_user_pages
starts decrementing GUP_PIN_COUNTING_BIAS, instead of just forwarding to put_page().

(For other readers, that's this patch:

    "mm/gup: debug tracking of get_user_pages() references"

...in https://github.com/johnhubbard/linux/tree/gup_dma_core )

> 
> That said, there are 2 differences I see between release_pages() and put_page()
> 
> 1) release_pages() will only work for a MEMORY_DEVICE_PUBLIC page and not all
>    devmem pages...
>    I think this is a bug, patch to follow shortly.
> 
> 2) release_pages() calls __ClearPageActive() while put_page() does not
> 
> I have no idea if the second difference is a bug or not.  But it smells of
> one...
> 
> It would be nice to know if the open coding of put_page is really a performance
> benefit or not.  It seems like an attempt to optimize the taking of the page
> data lock.
> 
> Does anyone have any information about the performance advantage here?
> 
> Given the changes above it seems like it would be a benefit to merge the 2 call
> paths more closely to make sure we do the right thing.
> 

Yes, it does. Maybe best to not do the temporary measure, then, while this stuff
gets improved. I'll look at your other patch...


thanks,
-- 
John Hubbard
NVIDIA

