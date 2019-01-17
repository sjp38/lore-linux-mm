Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1396C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 05:25:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75A2320851
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 05:25:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="QOWdO3Zn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75A2320851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0819C8E0003; Thu, 17 Jan 2019 00:25:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0093F8E0002; Thu, 17 Jan 2019 00:25:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC5818E0003; Thu, 17 Jan 2019 00:25:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id A81A88E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 00:25:08 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id t17so4573188ywc.23
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 21:25:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=044QbZMGoF7vRjhIGuWSKPJmv6TAL82gCvx5wUxoQg8=;
        b=Ex3r0xivMrWAicN9pBbEt7yOczdUoHrvfK/u87bu3T2hKClGCQVlZXnGC6npMsMcSz
         E2m9yQSPrRjlloDGfnSJv80lWMTmGC/ar/2K4cBXBkLL7q0JPETNGGFH2Gs6QDuK3tWQ
         5++2Z8EbeB3f18lCE9/A0X3AUyBMGzhdnGVRnqZJ6IgF+3vCCEThcdmqJbBG30OXeknn
         tQD8+NG45B4unfxi8Gajp8ffn8+JocIEyCaXOeVN/6K+zl0inofWVOUwW8uVfd1f7N6/
         JmLVIMs+mL1N36LusXcebON8KK7BK6D+uzJAU7GBu79xY5yF1cCbV/qr0CE8yvHdSowv
         OZJQ==
X-Gm-Message-State: AJcUukc3ZlelJ0+dVaFHiYEkXIGkJl9M87Nu4dKFOQyW5aHqyTrwPcV2
	YnnmMXRgKFvYi/obO0LOFoOXZ2hIjZ/s4VWK1w0N1vUsFtdSH+pxcQLHTdfx4wj5/v5vkYZGA6L
	n2aa7n0Dd0MjImoeZiAjIliRcgK1z6SqngaE0H934fy4V+3eKIJUZ7XYzaGi+YUL7TQ==
X-Received: by 2002:a81:ae25:: with SMTP id m37mr12257001ywh.14.1547702708314;
        Wed, 16 Jan 2019 21:25:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4YoI1KXrs8HzEchsnPjRk4jUcYKavQ+tBRsYZs3VJmq6RSfwHThbK2O/XnyYlPsLCaoj1m
X-Received: by 2002:a81:ae25:: with SMTP id m37mr12256943ywh.14.1547702707309;
        Wed, 16 Jan 2019 21:25:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547702707; cv=none;
        d=google.com; s=arc-20160816;
        b=ZUgj2coMIBtpVINFVTXBoa/yy8AMBrNZyomtfmEIoM/co0HUrFBuzpgxkJ/2ZBOcjj
         CQGW2YNrwXGAZ5wZFDa/TsL0stfCEM5bWPKHT0NNDHc6Mb2oh05+cjHADo1lVDyq71Lw
         Ws65Ph6TUmuOpjAEkX9xQEOfNS1UeMXfNQoctGwe5QF3F0okdrQ5XEAjp2eNwtVyWPO5
         2UlV3gOfU1aiun+Bo80nlFaCW8LVHZu6ErEYiR5lO8QVMzPyR7TBUX5t9diN89T2KHNi
         7D6W6RY+q9Lr4Xa/g8E/lvQki834yKXHxZ6+zfgZ/4fQBwzI66nIejOQf6UG9y/4sRaT
         iEGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=044QbZMGoF7vRjhIGuWSKPJmv6TAL82gCvx5wUxoQg8=;
        b=HIAVQhwhBZq3kBTeM05msAt2WVkReMZSzN3HiD2hHD+FN1yAuGzZByCCOnGabfDCSz
         TveNXZ5+djPIXRFx3X/l/imz4K7IWBvVg8li4oqlsTpGOQqfv+SUzF2tsDNDoejiUivB
         HVWoNn9vMDmz2xCqfVHNsxE+X4aWW2cGztjYyUAEN/3t3vdLl7lj+U1YKkTyBOXQjPwy
         b6dm4T2hFWDizpmUBgO3eSAC1QwYKHl/qZMTRuhD/oVUPp+2zdmDvuymy6LlRNqJ6oRl
         zb7xC6/D7k0q8O/9tHTfhTg4mhBsMpmlNeasQ/e9iknpn18+tqY+n0ZYXFNSzdHXJ746
         Lh8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=QOWdO3Zn;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 204si629073ywi.272.2019.01.16.21.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 21:25:07 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=QOWdO3Zn;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c4011a20001>; Wed, 16 Jan 2019 21:24:51 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 16 Jan 2019 21:25:06 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 16 Jan 2019 21:25:06 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Thu, 17 Jan
 2019 05:25:05 +0000
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
To: Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>
CC: Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>,
	Dan Williams <dan.j.williams@intel.com>, John Hubbard
	<john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM
	<linux-mm@kvack.org>, <tom@talpey.com>, Al Viro <viro@zeniv.linux.org.uk>,
	<benve@cisco.com>, Christoph Hellwig <hch@infradead.org>, Christopher Lameter
	<cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug
 Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko
	<mhocko@kernel.org>, <mike.marciniszyn@intel.com>, <rcampbell@nvidia.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>
References: <20190103144405.GC3395@redhat.com>
 <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <76788484-d5ec-91f2-1f66-141764ba0b1e@nvidia.com>
Date: Wed, 16 Jan 2019 21:25:05 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190115080759.GC29524@quack2.suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1547702691; bh=044QbZMGoF7vRjhIGuWSKPJmv6TAL82gCvx5wUxoQg8=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=QOWdO3ZnE05roJkVCzjAtF8fmAApbXuYJlSSSw1qj8Rdu1Ce3hEsO8Mv2AL56Y9wl
	 s6snFtEEo1+AXeYjCT2UIldUBoedH1sHNp5/Ln7WKkIyPdRVaXB7Whbgc92K74EJDo
	 UN2GchRAp9Nim4qPb8nJjHbHxwuvzXzZBa452wRqKkdqrfSrs1oub+2A7ndZ13bJoX
	 VcAVTR60FIyR8UpITHr7X5LkINjG0MHsGB5orXl5UJ3ZfWh2CQf3HZqE4vprs6dYPz
	 FaXP3M2FdMoVwZq9BQOf0/koDJSlC5ANHSf1Ju2Nof0cGer3e/3+yBb84TuOIxfnLz
	 c3866W2h/9pFA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117052505.6VmMFt7dceG1zRTt8YKDNbEEoOAr4y123b1D6nT9w2M@z>

On 1/15/19 12:07 AM, Jan Kara wrote:
>>>>> [...]
>>> Also there is one more idea I had how to record number of pins in the page:
>>>
>>> #define PAGE_PIN_BIAS	1024
>>>
>>> get_page_pin()
>>> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>>>
>>> put_page_pin();
>>> 	atomic_add(&page->_refcount, -PAGE_PIN_BIAS);
>>>
>>> page_pinned(page)
>>> 	(atomic_read(&page->_refcount) - page_mapcount(page)) > PAGE_PIN_BIAS
>>>
>>> This is pretty trivial scheme. It still gives us 22-bits for page pins
>>> which should be plenty (but we should check for that and bail with error if
>>> it would overflow). Also there will be no false negatives and false
>>> positives only if there are more than 1024 non-page-table references to the
>>> page which I expect to be rare (we might want to also subtract
>>> hpage_nr_pages() for radix tree references to avoid excessive false
>>> positives for huge pages although at this point I don't think they would
>>> matter). Thoughts?

Hi Jan,

Some details, sorry I'm not fully grasping your plan without more explanation:

Do I read it correctly that this uses the lower 10 bits for the original
page->_refcount, and the upper 22 bits for gup-pinned counts? If so, I'm surprised,
because gup-pinned is going to be less than or equal to the normal (get_page-based)
pin count. And 1024 seems like it might be reached in a large system with lots
of processes and IPC.

Are you just allowing the lower 10 bits to overflow, and that's why the 
subtraction of mapcount? Wouldn't it be better to allow more than 10 bits, 
instead?

Another question: do we just allow other kernel code to observe this biased
_refcount, or do we attempt to filter it out?  In other words, do you expect 
problems due to some kernel code checking the _refcount and finding a large 
number there, when it expected, say, 3? I recall some code tries to do 
that...in fact, ZONE_DEVICE is 1-based, instead of zero-based, with respect 
to _refcount, right?

thanks,
-- 
John Hubbard
NVIDIA

