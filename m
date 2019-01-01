Return-Path: <SRS0=ID2a=PJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E1DAC43387
	for <linux-mm@archiver.kernel.org>; Tue,  1 Jan 2019 09:23:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1C1C21871
	for <linux-mm@archiver.kernel.org>; Tue,  1 Jan 2019 09:23:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1C1C21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 901648E000A; Tue,  1 Jan 2019 04:23:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 888598E0002; Tue,  1 Jan 2019 04:23:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 751738E000A; Tue,  1 Jan 2019 04:23:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48B7F8E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 04:23:24 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w18so35919304qts.8
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 01:23:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=uHYL6H6jhEBXfi1KWXawY2Y947WQJsevLiPE6J30XeE=;
        b=NiSDnrjChG2uw/EAeUhk7wmUKSP+88lp+c0ErRbpZKuQs37JT1HyDFOyvVzRHlDdJ5
         lyEgGG7r6wbR1cNxUfSMksKrZme0y2hBu/2CYhJ5eXVn+nb3NC6ZFHnUTnCJpmCM756l
         VOIGGSzxeyctWmSwbXv5RyuhvZZXuCUIe7FcbiRdl36JqqKh01JW8SKHq9F9AcqHCPKZ
         3Ir14tu2GezBOgXmrkSky4LswZ3MU64dSTEMj+OOstpPQ4n2D2gk6ER0kPj99G+DHrGs
         TN9SeR4PIOXXA9eQaRL0uZjS28LbQ1bboMxAYa1IlwKkCL/+HOycaa0lIAwqMqlwlzwR
         +3wA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukfBIEUvSaYEVni0znFrG0y9epYj97y8ZqKic/XG0/u4Wyt0n3qE
	NeAvZx+pbrW5tEBImFUz0mdodope35Y3ydVY2OZXxJoVrn4AXBBsD3RbUjmigJsQEHPX937fIM/
	YV9IQ7tpo8vzUZq1/pL/+ORS89M7MA3QOMRQIqGHlAEXGhia69oykQzt8V8ssxm8swA==
X-Received: by 2002:a0c:96b5:: with SMTP id a50mr38857549qvd.33.1546334604037;
        Tue, 01 Jan 2019 01:23:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7U2lkb2NcQnZyQIhDx6mYkZkvcg/Q9jQdsF4J0w6jn1xteyiQwWwLmuJkdWVvnTedLAmy4
X-Received: by 2002:a0c:96b5:: with SMTP id a50mr38857536qvd.33.1546334603547;
        Tue, 01 Jan 2019 01:23:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546334603; cv=none;
        d=google.com; s=arc-20160816;
        b=lN5LPVPbPiCBr/iMW/DsoDNmartbexvPjbBwaUw7cciRRSsuWp3PVeY/7JSZJQ/dmr
         8iMtKLNNXrU/nNSdKALb2gXfF1MX7MWe5Rf4Jvb7vEK/ylgMhrCarZY8kFTDmoznchg+
         /PMAbikGQEI/xKwwXrRjoEYczMio4eugNlQjX/gHDfxW0+eWREUqs0poFOIOXUOf3MaH
         pS1n9g6IG8DJfya/ItxoZv8V6+U9gj9xQxhMONBm8C+UgupIlZawd0XaP/fAUTLGRGsx
         AeSAIEeytFWthf1fToLoYTpg6HkZ+7RbYhL4vKMaDGyI5O902ajvjEq6qcVDkzbHrxCJ
         lwWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=uHYL6H6jhEBXfi1KWXawY2Y947WQJsevLiPE6J30XeE=;
        b=e+epDpGMNHh2XJHW6guH0x+T2KhIqiZHGIuuyjRNUKTQaBG7Hb7bMTZQcJ213S8HNP
         yxjE5jg3ewsNPYAx7E8QFisrgU4cmdNugkMo5fySsVlr7e9TtTi60qfKVWOSAW8Iu9HX
         sgaTkSmqVpy9a4xamEMe9gEaymg5Y975TNzK3uhpDTJRdlXm2W8sTbJoY2MTIv9yfJ+j
         ZOyJUTtK+dmtbGdrCErolv5cKcPrYgx710ITPbEfTFKf2n+yBhUvz979NFeYDcckiEjw
         I3cHHVum0Z2OANIzBPXzMW0Yf79Sq/C/W7wRAGjK0jJJtGFWr/m/7oHbM5YxuESIk5ls
         /T7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b9si1302364qtq.169.2019.01.01.01.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jan 2019 01:23:23 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x019KAX3044671
	for <linux-mm@kvack.org>; Tue, 1 Jan 2019 04:23:23 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pr417u1ka-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 01 Jan 2019 04:23:22 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 1 Jan 2019 09:23:21 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 1 Jan 2019 09:23:16 -0000
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x019NFSu55902356
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 1 Jan 2019 09:23:15 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 46DDB4203F;
	Tue,  1 Jan 2019 09:23:15 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DDE7142041;
	Tue,  1 Jan 2019 09:23:11 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.88.250])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue,  1 Jan 2019 09:23:11 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Fengguang Wu <fengguang.wu@intel.com>,
        Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>,
        Yao Yuan <yuan.yao@intel.com>, Fengguang Wu <fengguang.wu@intel.com>,
        kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Fan Du <fan.du@intel.com>, Peng Dong <dongx.peng@intel.com>,
        Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>,
        Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>,
        Zhang Yi <yi.z.zhang@linux.intel.com>,
        Dan Williams <dan.j.williams@intel.com>
Subject: Re: [RFC][PATCH v2 11/21] kvm: allocate page table pages from DRAM
In-Reply-To: <20181226133351.703380444@intel.com>
References: <20181226131446.330864849@intel.com> <20181226133351.703380444@intel.com>
Date: Tue, 01 Jan 2019 14:53:07 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-TM-AS-GCONF: 00
x-cbid: 19010109-0012-0000-0000-000002E010DA
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19010109-0013-0000-0000-00002116C9E6
Message-Id: <87pntg7mv8.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-01_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901010086
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190101092307.7a_HrJd1NGwwAT9SmLqJRcfSBPNpGChUwzLS2rfYwe0@z>

Fengguang Wu <fengguang.wu@intel.com> writes:

> From: Yao Yuan <yuan.yao@intel.com>
>
> Signed-off-by: Yao Yuan <yuan.yao@intel.com>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
> arch/x86/kvm/mmu.c |   12 +++++++++++-
> 1 file changed, 11 insertions(+), 1 deletion(-)
>
> --- linux.orig/arch/x86/kvm/mmu.c	2018-12-26 20:54:48.846720344 +0800
> +++ linux/arch/x86/kvm/mmu.c	2018-12-26 20:54:48.842719614 +0800
> @@ -950,6 +950,16 @@ static void mmu_free_memory_cache(struct
>  		kmem_cache_free(cache, mc->objects[--mc->nobjs]);
>  }
>  
> +static unsigned long __get_dram_free_pages(gfp_t gfp_mask)
> +{
> +       struct page *page;
> +
> +       page = __alloc_pages(GFP_KERNEL_ACCOUNT, 0, numa_node_id());
> +       if (!page)
> +	       return 0;
> +       return (unsigned long) page_address(page);
> +}
> +

May be it is explained in other patches. What is preventing the
allocation from pmem here? Is it that we are not using the memory
policy prefered node id and hence the zone list we built won't have the
PMEM node?


>  static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
>  				       int min)
>  {
> @@ -958,7 +968,7 @@ static int mmu_topup_memory_cache_page(s
>  	if (cache->nobjs >= min)
>  		return 0;
>  	while (cache->nobjs < ARRAY_SIZE(cache->objects)) {
> -		page = (void *)__get_free_page(GFP_KERNEL_ACCOUNT);
> +		page = (void *)__get_dram_free_pages(GFP_KERNEL_ACCOUNT);
>  		if (!page)
>  			return cache->nobjs >= min ? 0 : -ENOMEM;
>  		cache->objects[cache->nobjs++] = page;

-aneesh

