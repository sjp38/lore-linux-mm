Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE271C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:05:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93A182177E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:05:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ABVkXe49"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93A182177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C55C6B0290; Thu, 23 May 2019 15:05:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 375A46B0298; Thu, 23 May 2019 15:05:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28DB76B029B; Thu, 23 May 2019 15:05:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08EE26B0290
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:05:18 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id k142so6222468ywa.9
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:05:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=YP2OrLXcg7+GgleBA75F5zjB/aDAnmSGT6B98RFmL+A=;
        b=Ayzrqw3PxPjeBlrewa8FJ1kGTl1gA7SWZEbA2qB5mZLcHbsZwWMzzUD9N3fBVX9gbD
         l7bfBuPOpd8HmxnVViU4u1S1QbbhyYh59i1Q6frGHgAQNA+3tn/N1aOUwwD9JdnIam3E
         kQLyBAVV/UL2XYzptoUYfVvlnrDRqDJjzlrFO8MaEkWJKzGmd54Q5nnurBFR1hBJqfQS
         Cf+prwjf8/C6PS4wOBljhsuuU08OVNwxIJDG5vu3z0tBRLtnRZ30ookAcV2j15/fuhTF
         Tj6ErjRbnkOVECeCBQhGpRfMH1L36Ljr4+Ot5t4mlxFQzljvL4qOOoZ4qkhUMbFzCAHh
         mkmQ==
X-Gm-Message-State: APjAAAXxWI3EeeX877oCn8s+koFhmlABts5wSqNQbit3SnnieyUkFJBp
	cO4qqLpz/0P1sWgM4PnYM8jl0JOsZ69dNHjpzp09iukRwQIPH9z7pslU/vJGr1c/hynmVlv2Rft
	LXUk7Cv4i82WFPSP/nVF1GF9sq7JjvHTTGXf9HajesgFGILvMrL9GOIUV0+LVFPh+AA==
X-Received: by 2002:a25:3803:: with SMTP id f3mr18434812yba.158.1558638317774;
        Thu, 23 May 2019 12:05:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZfhtl2rrCsEU4Sd9CtPMlW/j31Vjq1ftMQQmno9+UCZZdXtehpKIxZeZVz3Yks7NbA1U+
X-Received: by 2002:a25:3803:: with SMTP id f3mr18434764yba.158.1558638317108;
        Thu, 23 May 2019 12:05:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558638317; cv=none;
        d=google.com; s=arc-20160816;
        b=CC8s/kz/B8wkaCrdOxGxvkJPFHu+paj922F7dnKMstWEdMqos+8FianIl0ZpFHZJQ9
         H7JWR6h3heMxtlleYLdrgAIVE6la8k7D9nvyxVjgbnP4Lj8FrAO3c+gCVTt3zHKjB660
         8p86MbmUVhDrTaauU8BU++7gnOt/13+weqlPVSvAxrqGgka+WmyLWqmFbDsUmye1J0Aw
         GzGm944/ejwHkba/TSHfNsGsEHYPkcXAcMk2abPcB9qYSVrS1SZp9V9ETZHRPOOvi5eU
         y+X06HHHvU0+b147sw/Bzw3siEUI/SOmgGQdM5ScE/7M0zKuw5V+Ckh+GAs2AO3F0IMH
         VEjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=YP2OrLXcg7+GgleBA75F5zjB/aDAnmSGT6B98RFmL+A=;
        b=t+GVkoF+b9WvrvB3Zcr+XX1zTDU74936jjC5hNsnhbdYEiOU8HJycvgTvfDHv7WBJJ
         j6VU0g7vCkwH9Hd+bcSeQPEM5omzfif5hEVUoG20ncJ1ulSkoq+B8OON5wgFoU7gNCSY
         tVaGhq8T4lUC4cGuKQg4dh7NYjq5vJTtCEB0s2ds/x/T7hi4enKrygF5xI3Tl9d2YPGl
         EtqPOmDBWyJuHrT9zAUDQQruehiN4W8PkIm0OAuCNa7u71NtAQEkLkwfSVfwyH2UPXwz
         LC1dfSSgtcjsSipjdteSt8Z8u7+GKRiGdO+6Qhqxz8EaCxWehZeh1Wm+tFAuQqymfSn+
         9BWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ABVkXe49;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u73si57315ywu.227.2019.05.23.12.05.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 12:05:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ABVkXe49;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce6eeec0000>; Thu, 23 May 2019 12:05:16 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 23 May 2019 12:05:15 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 23 May 2019 12:05:15 -0700
Received: from [10.2.169.219] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 23 May
 2019 19:05:12 +0000
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
To: Jason Gunthorpe <jgg@ziepe.ca>, <linux-rdma@vger.kernel.org>,
	<linux-mm@kvack.org>, Jerome Glisse <jglisse@redhat.com>, Ralph Campbell
	<rcampbell@nvidia.com>
CC: Jason Gunthorpe <jgg@mellanox.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <6ee88cde-5365-9bbc-6c4d-7459d5c3ebe2@nvidia.com>
Date: Thu, 23 May 2019 12:04:16 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558638316; bh=YP2OrLXcg7+GgleBA75F5zjB/aDAnmSGT6B98RFmL+A=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ABVkXe49Iwt9HNArMqPpHmNl0uJRGzlQvFw8q92phwZF7JmzwKUNZOaNCTi4Wht9w
	 2wNftys44mCri3WYu2IQsS2msA6zvIaHCp0Cvz8q/YjbkPDIKq5FTeqZu1sxr89D4b
	 ETwGXxWTZ7LjM4ajaIOSMJb5z53WNPrhPwx5kNkFvNrISKpc8+UziwycRt5zENV+V6
	 aAIVE0rDiZ/8+aNThPhKyWCWdv7hifp8UaGKiip1BrYHprhY5UlhjLLSFbym6ZcvBa
	 Spflg8pZ4Ap8Q3REzEIkaKoWwuNIXzSTlv5sesMjG46x194a7GNeebHGp9IoEmoknK
	 eZ9FzMjZUpzbg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/23/19 8:34 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> This patch series arised out of discussions with Jerome when looking at the
> ODP changes, particularly informed by use after free races we have already
> found and fixed in the ODP code (thanks to syzkaller) working with mmu
> notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> 
> Overall this brings in a simplified locking scheme and easy to explain
> lifetime model:
> 
>   If a hmm_range is valid, then the hmm is valid, if a hmm is valid then the mm
>   is allocated memory.
> 
>   If the mm needs to still be alive (ie to lock the mmap_sem, find a vma, etc)
>   then the mmget must be obtained via mmget_not_zero().
> 
> Locking of mm->hmm is shifted to use the mmap_sem consistently for all
> read/write and unlocked accesses are removed.
> 
> The use unlocked reads on 'hmm->dead' are also eliminated in favour of using
> standard mmget() locking to prevent the mm from being released. Many of the
> debugging checks of !range->hmm and !hmm->mm are dropped in favour of poison -
> which is much clearer as to the lifetime intent.
> 
> The trailing patches are just some random cleanups I noticed when reviewing
> this code.
> 
> I expect Jerome & Ralph will have some design notes so this is just RFC, and
> it still needs a matching edit to nouveau. It is only compile tested.
> 

Thanks so much for doing this. Jerome has already absorbed these into his
hmm-5.3 branch, along with Ralph's other fixes, so we can start testing,
as well as reviewing, the whole set. We'll have feedback soon.


thanks,
-- 
John Hubbard
NVIDIA

