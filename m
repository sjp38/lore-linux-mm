Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 146EFC282C7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 02:22:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A502E2175B
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 02:22:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="sPI+brV6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A502E2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 120248E0009; Tue, 29 Jan 2019 21:22:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CFA28E0001; Tue, 29 Jan 2019 21:22:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F001A8E0009; Tue, 29 Jan 2019 21:21:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE5508E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 21:21:59 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id t9so962136ybd.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:21:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=fhXjDs+tpYnR9fC2/TPq13qS+GooJ05aAT+eGKah/Nc=;
        b=o7XertBDDQcw5LsNaEiIpNYUMewYwEaiZsEuXZFfOZG0tNLCD2n6tBWjhrDye0rQF4
         U8Or1Fv8e+VakUx/n6JUYbdO6Qm4Z5P7Wk0dWJiRggaK0tJvM/vKSqfMswTdkToAAdO6
         oJzI+4H/CD7k6maATnoA3L1kKzMFT6/HZFARCBhb6LX7NC+WiaqeuhioQx2xaZUndZHn
         r9uvWnscI5R8CDplyYReN1RM4+bdSEYX0vTrvk5ScAxLo2B5x20LZePok8qfvF4iNp6j
         5VplaxU1vo0Me5nVSCUL+HObqBbMhBLRu2NKa4yH1g4XHYrGVtNVKV78ZFx9Lku6hnOo
         3YAg==
X-Gm-Message-State: AJcUukf1n+zeoRt/5POxotEBW76DrQNrjxRdSO4+d+4Q7GZKBUmiNvCC
	fNS7m2KNfdCM4rg5w5PHuFYxytTz9YXhUcjz9KlYwJPIGr3Ru6CgqZhKzpdd/SbXy2cniH8wafs
	Oc4AHQUMSDf9SwOS1y1BVSC/d4C91hXNEnttMSQMGvMcGPWDpqTbiclNAZ0PqCBdD9A==
X-Received: by 2002:a25:dc43:: with SMTP id y64mr18989509ybe.476.1548814919449;
        Tue, 29 Jan 2019 18:21:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6IOPNDQl4lC7kfZQ+9nxX26+Pfw29C1uQON6E2/sX+rkrhgvVSPk/2Be/D49BO1YpM1JGr
X-Received: by 2002:a25:dc43:: with SMTP id y64mr18989476ybe.476.1548814918502;
        Tue, 29 Jan 2019 18:21:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548814918; cv=none;
        d=google.com; s=arc-20160816;
        b=SScdovYf7GPkDDemG6TgRLdS5dngVI+/lB2BwtsWEU/FFCGOd2V8pX9SUO3WrBvdCJ
         xrqZIbsq8+Nch2Oqdor+pr8KKfaufXFM5Hkg9EE4VFWo1OSsfuoEFbD7wrUOT+OouaGP
         6eGVJKPzHi1BIze8sS7h/hme+duKI9xRLmN6cVj9u6G5+SuPPu2SkA4UUSeBH5JW1pmp
         fq4CliYqXHoSzxGctWdPpvtJSVfjMmEFaUfLjJgDqshbPTO/bHtcp8gAMMYPNooRH2e7
         hH6D/Wu4mcKagRLnFPePIb2XgyrCn8aIOXee/XMxY2qLl8EahL9JD+pwdZNosKAlzCFc
         xZ1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=fhXjDs+tpYnR9fC2/TPq13qS+GooJ05aAT+eGKah/Nc=;
        b=igunLKfbOiOIOeNsZUQk0alJVfjX1xSegtWTLiDTKG+1xYzQW1dCfEhQPHn1bS9F3C
         heb72+D3vjCUWrZZpLLgmrNEVnjOskdO8gma6rskbZnMLLYT2ZCW0HK6+azbLPg8+MXY
         KjM/DCSjSJ/Yi3tc8LmsU6Hzgd9iVrQMkvLopfkmlxcNZFqFv+LcIbtOn5LBkfUsm94d
         a2G5AniWLHLjau6kP9Gf951wUAgzwwxbc3rYuxJqrP1y3jVsmPz5TaaQnALepJPYQEX5
         PNO1PNah4px3E0IutQk2wa/ENnCDK0/uGbBfW9U47ly3/wGpSPH8qLowtKrwLZuh5HEr
         GRNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=sPI+brV6;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id f15si82659ybp.470.2019.01.29.18.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 18:21:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=sPI+brV6;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c510a290000>; Tue, 29 Jan 2019 18:21:29 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 29 Jan 2019 18:21:57 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 29 Jan 2019 18:21:57 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 30 Jan
 2019 02:21:56 +0000
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
To: Jan Kara <jack@suse.cz>
CC: Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>,
	Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, <tom@talpey.com>,
	Al Viro <viro@zeniv.linux.org.uk>, <benve@cisco.com>, Christoph Hellwig
	<hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro,
 Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>,
	<mike.marciniszyn@intel.com>, <rcampbell@nvidia.com>, Linux Kernel Mailing
 List <linux-kernel@vger.kernel.org>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>
References: <20190116130813.GA3617@redhat.com>
 <20190117093047.GB9378@quack2.suse.cz> <20190117151759.GA3550@redhat.com>
 <20190122152459.GG13149@quack2.suse.cz> <20190122164613.GA3188@redhat.com>
 <20190123180230.GN13149@quack2.suse.cz> <20190123190409.GF3097@redhat.com>
 <8492163b-8c50-6ea2-8bc9-8c445495ecb4@nvidia.com>
 <20190129012312.GB3359@redhat.com>
 <3c3bb2a3-907b-819d-83ee-2b29802a5bda@nvidia.com>
 <20190129101225.GB29981@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <1e4e9c5f-c04a-0e8e-cdfb-b41e365cc2a2@nvidia.com>
Date: Tue, 29 Jan 2019 18:21:56 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129101225.GB29981@quack2.suse.cz>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1548814889; bh=fhXjDs+tpYnR9fC2/TPq13qS+GooJ05aAT+eGKah/Nc=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=sPI+brV6Qvw/eIScEgWNgUoEvVL196Fgzc04hVs5GBaB8Rk8KYZVPak3EyeDQwzkJ
	 53atJ5nzMIrLtx0nUOU2Qrm/tOEStFQUGy7NEgJEnrzi+8M6cuhOyCZYCAFQzGvZgY
	 uAF//7owMXO/sGw0hSJPAtCdIVA32fkAEQoGkjG3On8pdYURsezHM6IH0gysC8Ason
	 WrU3V8JLeChDW6y5KMA2yh5xSHa6J2Uw70jeRTfraQxT7wLnoDhMqXl2mtQQNOKCua
	 RyFyxucd2MaJBEW0O5tEpa2PxijtV75UrYcc9gql21NkQuzcoEWy2dJkXpTXWQI5b0
	 EpFZMJA3cNb1Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/29/19 2:12 AM, Jan Kara wrote:
> On Mon 28-01-19 22:41:41, John Hubbard wrote:
[...]
>> Here is the case I'm wondering about:
>>
>> thread A                             thread B
>> --------                             --------
>>                                      gup_fast
>> page_mkclean
>>     is page gup-pinned?(no)
>>                                          page_cache_get_speculative
>>                                              (gup-pins the page here)
>>                                          check pte_val unchanged (yes)
>>        set_pte_at()
>>
>> ...and now thread A has created a read-only PTE, after gup_fast walked
>> the page tables and found a writeable entry. And so far, thread A has
>> not seen that the page is pinned.
>>
>> What am I missing here? The above seems like a problem even before we
>> change anything.
> 
> Your implementation of page_mkclean() is wrong :) It needs to first call
> set_pte_at() and only after that ask "is page gup pinned?". In fact,
> page_mkclean() probably has no bussiness in checking for page pins
> whatsoever. It is clear_page_dirty_for_io() that cares, so that should
> check for page pins after page_mkclean() has returned.
> 

Perfect, that was the missing piece for me: page_mkclean() internally doesn't
need the consistent view, just the caller does. The whole situation with
two distinct lock-free algorithms going on here actually seems clear at last. :)

Thanks (also to Jerome) for explaining this!

thanks,
-- 
John Hubbard
NVIDIA

