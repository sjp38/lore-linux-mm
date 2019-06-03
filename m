Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D329C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 18:43:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F7F72709F
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 18:43:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="EnoXFOp4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F7F72709F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99D5D6B026B; Mon,  3 Jun 2019 14:43:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94E1B6B026C; Mon,  3 Jun 2019 14:43:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EEB66B026E; Mon,  3 Jun 2019 14:43:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6D56B026B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 14:43:14 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id 77so6594306ywp.14
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 11:43:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=tKMLEaAhTvHGtWnrzz8Y9cwKJSlyaoFHXkpuvZCE2A0=;
        b=FSIPvmNy+OgJ25iLKRFe5wuLU+/YXHUpyUjK0A5wcuH0Rk3TqLEEwrocILNLifqYq2
         70mbr3sAgKOe2qbizG1DHKh8aTze87zeSp1p35x6ybfbmSMue9OfPqx75ciRAgS6gjIZ
         3Caa5SnYe76uEF0S6ylL5WDmofSWU04HkcmI/M6R60tHhnrM7NMFOTIbBf0nBjYO8JAw
         1rBsGn4VzQsczhDqO/suvRVy0mbV5bai2P6KXNdezDmahQjuq8JOfiOxab27DDXP957F
         KqJgCBOU381clndCs0SOnJbr5PtyF7qsdYwEEaN835/LAB1xhu8C6hkADoRNuhIM6PHt
         91Mw==
X-Gm-Message-State: APjAAAWqBKJ/u/KPz92qyikiF6pGxqnAPeiR66/8B/CRSeND69jgBjRs
	Yyfs059G7W2+rTqWzVd/8HRF5PnNmTw1yOHlra/RhGbq/Ked8UhYWsXbZz60o1USuD5c5X65e47
	XeiEPz+ug7QK9qapxrUf8vhxch3qTxuWaLQi+6+y5YFks0q6irfMTS23sQEsOBjpSfQ==
X-Received: by 2002:a81:a408:: with SMTP id b8mr8056156ywh.5.1559587394139;
        Mon, 03 Jun 2019 11:43:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZKqxivyHCYrHfAdvrxoMGUBofA970PISHqbQGk2+ER1eBaXLdolU6P1rNGEdaRu8NgEY2
X-Received: by 2002:a81:a408:: with SMTP id b8mr8056133ywh.5.1559587393576;
        Mon, 03 Jun 2019 11:43:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559587393; cv=none;
        d=google.com; s=arc-20160816;
        b=0YoFBwyLOfUQPpq7CvaDFjmtni0Jx9R87/YgdocVMpqCpa2gpmw5NrCwLbs96gXrS/
         WM2S6z467HTaWZctEHuUzm7iMKGYaK9UXEOwkjeEkm94vTmPYjFYAykY83XRR9ubFUNz
         6S/Rp1xh08kDhSspI1Cyd21ScJRxUV2NjAhap/DwOXIOk4bGxFJ1SgVYA670kpvrHby6
         r9kJDyhs+2H4isaIzsKdJIJUkUcg951uzwUInh8/ZYE3q6IlghNjn5gXIHYbTrkjNCrs
         O1dY3mxEjz0UAjyI4b9Yv/FJBewNDfQFsglGExXqdwLBBH/KRIu5qs7PEtp/YmpejvPF
         xecg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=tKMLEaAhTvHGtWnrzz8Y9cwKJSlyaoFHXkpuvZCE2A0=;
        b=pSV/iAjgnOyCveP0mMi+cOPNfm7ZJnGd8HDZaxgzhxYDuZ21laU9uNBLi9I9qwcHRn
         y3el4mMIz3lkKdVFGXUOv7bsC7LTl/6Mt+CTIlsHcMxa0ieY6T8eSSgI1DygwV96/Dmm
         bikEPVQt/hrjqlxh1qdZn7WVUVSc8GEgW0XqMHaD2DvYeJMuzSrsBtX+N5X8oIamLzT1
         sxrTfNHr4ySr6vofQERoJF2bKyvLfmWV/CYD30l2OY/evfv09k8X7WzexFOYLWgg99LM
         BuHKjEAtbEQcUZ9atAZ9lP4O4BQjDS+r56A0ZUi274avYiAC7EC4hG7t6LmdEVZzg3VD
         LkAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=EnoXFOp4;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id f15si470107ybr.404.2019.06.03.11.43.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 11:43:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=EnoXFOp4;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf56a3f0000>; Mon, 03 Jun 2019 11:43:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 03 Jun 2019 11:43:12 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 03 Jun 2019 11:43:12 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 3 Jun
 2019 18:43:12 +0000
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
To: Christoph Hellwig <hch@infradead.org>, Pingfan Liu <kernelfans@gmail.com>
CC: <linux-mm@kvack.org>, Ira Weiny <ira.weiny@intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, Dan Williams
	<dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Aneesh
 Kumar K.V <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>,
	<linux-kernel@vger.kernel.org>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
 <20190603164206.GB29719@infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <e389551e-32c3-c9f2-2861-1a8819dc7cc9@nvidia.com>
Date: Mon, 3 Jun 2019 11:43:11 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190603164206.GB29719@infradead.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559587391; bh=tKMLEaAhTvHGtWnrzz8Y9cwKJSlyaoFHXkpuvZCE2A0=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=EnoXFOp4nnKg7XB85C6vLhLu5jGXvkiEskUyqiNtuHiP+yhdwuGTx9jnOAyrQHvu/
	 4AhbZ0bRb7cxdYTgqFcWLsFPGwzVgL4gaU4BmtePyrDlTLBvjThJM6kbkoFVVSxcAT
	 RB+yVQWqZVURxEzPBMNRuoeoG0d91LsVcQJTWpYSiNKCd0SFbf9e3c9aDfAEn3zm7T
	 yR8wpPlMJ8whkpuUQri/teUXWWrgYpRx1KMnNlUSJvdrqD4JNeHNR0WilS5Kh2/Z0+
	 vDckDLxe3BMnXSO9PqNDlP3jOM9jwwa1+H1UoiCM4GTnysrcWWsaLFTB4lL6RDopv6
	 0PBMWHh7/W63A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/3/19 9:42 AM, Christoph Hellwig wrote:
>> +#if defined(CONFIG_CMA)
> 
> You can just use #ifdef here.
> 
>> +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
>> +	struct page **pages)
> 
> Please use two instead of one tab to indent the continuing line of
> a function declaration.
> 
>> +{
>> +	if (unlikely(gup_flags & FOLL_LONGTERM)) {
> 
> IMHO it would be a little nicer if we could move this into the caller.
> 

It does feel wrong-ish to loop through potentially every page that
gup_fast just followed. But could you clarify what you had in mind just
a bit more detail? For example, in qib_user_sdma_pin_pages() we have:

    ret = get_user_pages_fast(addr, j, FOLL_LONGTERM, pages);

Should this call a filter routine to avoid CMA pages, is that it?


thanks,
-- 
John Hubbard
NVIDIA

