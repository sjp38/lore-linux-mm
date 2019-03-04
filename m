Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB341C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 23:11:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87C58206B6
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 23:11:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="M4EdluFM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87C58206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D22298E0003; Mon,  4 Mar 2019 18:11:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF8E98E0001; Mon,  4 Mar 2019 18:11:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9B438E0003; Mon,  4 Mar 2019 18:11:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72A8C8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 18:11:08 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x17so6977481pfn.16
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 15:11:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=AcOE5zfOZlN0A/nrsbhxxR+K8ncz9Jke8a4dU/jfTkI=;
        b=nS9eQsgwWntQ2ynNzZyQdsTCMAIaZZ4990IsEsgqSULdHRBRwBIu42BI7sPqOM5Ri+
         lR+7vmPQNMbEHhstXum6fCKdJjlKJuhT3tO8xJaZO0IoTQQRddzECqJathpQ4qHkNMdB
         m4aeC6s2O7g4op6c6I2a0XJiIKStKEyFWUViXbIi6ISvTxWBe/YMLRyHL3p9BtlhPJtT
         2gE3ROIMSv9P0YY/ivf1I+rR6vyOLcosLxpWCFUrV9TID0yAdatamz6IHwQSt93ilahl
         deT6BRsWhPReufuQX3xOxjbGTg9gY6mmJk1+u5WGtwSmPeXCAM7yw25MQwV+3gYgWhre
         qqcA==
X-Gm-Message-State: APjAAAXuW8dFVgyz4RVwPmzCW06gNNBnB0PydM7QV/lmwIzc9b9P3lsf
	cLnl//83ePBCWp6ScMqiSqIZ9A297EvAkd8Fek83Gsto0YbfXgbIwMO6iik/VbBOB/K2beAuvtR
	NjhOIYlm3/2ZTIwCddKmSMDjh0/R8ega2buBGaiVayj+zMnhlXlIG3lBJ3+7VxlBrVg==
X-Received: by 2002:a63:c0b:: with SMTP id b11mr17685491pgl.388.1551741068030;
        Mon, 04 Mar 2019 15:11:08 -0800 (PST)
X-Google-Smtp-Source: APXvYqxUUtCPKYkvlMxwW/k0qoVkuNUqBQE/D8qAWNBlWYejtPMBS8IqXmlWzhufJd2Hcsw5JHc7
X-Received: by 2002:a63:c0b:: with SMTP id b11mr17685408pgl.388.1551741066887;
        Mon, 04 Mar 2019 15:11:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551741066; cv=none;
        d=google.com; s=arc-20160816;
        b=ZyizzCOwj381ywcUXbJ+1J/unRTC1tcpf5s1EiycOcfLsicC/3EgIGNTo2o2Gb58Ix
         F7un55TjXkBNeEjF5cEuNeg9f7sxIz70P45YhMrWsQc5lpaIN3+bzaJzq1lJpGpY7NcV
         Msi0NoDf5WT61Eiof+SX4K/aOlXuEuTq432bMnaJmwMvOCBykNZTPtv05m4aZfF9IDq1
         pM9q8Aw/NA+EdKogErtXp7ti5ho5RBEVwyXeqAHvf+JRnGPoWxSwSbPRquOrESNK6CgP
         Rm6xRj48zNmATJwubA4oey7q/8JOrecTCnpRw+tk+fpkM3PLM3dg/hO2tWWPRPyH21rH
         xiOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=AcOE5zfOZlN0A/nrsbhxxR+K8ncz9Jke8a4dU/jfTkI=;
        b=QykLy9wc2dQWQJvY/YvAFS7Pmd99ZbbgN7hPzZzfMh8jMqXH7xW3csU8RHRIa8Xijb
         moFiwejMpOLUzoVXhb8Nay37yUgWlnSsCfVfdHOU4mD7SiO2hb/ymMTaJwtFxIJOPPKg
         YJxQqMbtIAF/TbnOudCe2ewnHUuo+CX94adgp8beg42Tn+kl/ftYUSeDfXeFsP88CN/F
         uqNPS3fhpZSi9WWXGt4fci1UknxOXUy3pgGpe5QCY+nMXEU1Hr7vba7zvtV603Cd9MtY
         9KWsIzkLkKJji6mVtZR4NkPjiHDoqDHSMGTaup2Qz69qEhWTM2TTaKuiZhUxa27Ogw2l
         tjOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=M4EdluFM;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id f17si6397578pgj.61.2019.03.04.15.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 15:11:06 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=M4EdluFM;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7db0890001>; Mon, 04 Mar 2019 15:11:05 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 04 Mar 2019 15:11:06 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 04 Mar 2019 15:11:06 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 4 Mar
 2019 23:11:05 +0000
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error handling
 paths
To: Ira Weiny <ira.weiny@intel.com>, Artemy Kovalyov <artemyko@mellanox.com>
CC: "john.hubbard@gmail.com" <john.hubbard@gmail.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML
	<linux-kernel@vger.kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford
	<dledford@redhat.com>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <20190303165550.GB27123@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <bef8680b-acc5-9f13-f49e-8f36f1939387@nvidia.com>
Date: Mon, 4 Mar 2019 15:11:05 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190303165550.GB27123@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551741065; bh=AcOE5zfOZlN0A/nrsbhxxR+K8ncz9Jke8a4dU/jfTkI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=M4EdluFMzpFbdlvmJgg9sDSyl9ybTTuXn2Ye4Uo4+uio+hXE1LugAMTN9FJeMixOh
	 xM4ZkJG6F+lws7n4aKQ87vfBeTbGrR4P5kVTqpVw3SeOIiHyPis4GpqaPWq9vI9C5F
	 WX6vr4ecIWxnmRYksYumBMASeqgSajxi1jb6NIos2qZL0mp73McyUDW80MWsV9e6HQ
	 ZL+/ub+nAfcqO4AwPcC60pc4dJI4wAHUkfa6tO6io8hqvFYy21TMt+FrgL7TKcHsua
	 eT57n4DnctCLzUBjgeNA5sZY02hizFRl7N+JXl7F8DkHU224BBfpm40nuO22362lD/
	 2XtwsbR7rlqbQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/3/19 8:55 AM, Ira Weiny wrote:
> On Sun, Mar 03, 2019 at 11:52:41AM +0200, Artemy Kovalyov wrote:
>>
>>
>> On 02/03/2019 21:44, Ira Weiny wrote:
>>>
>>> On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrote:
>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>
>>>> ...
>>>> 3. Dead code removal: the check for (user_virt & ~page_mask)
>>>> is checking for a condition that can never happen,
>>>> because earlier:
>>>>
>>>>      user_virt = user_virt & page_mask;
>>>>
>>>> ...so, remove that entire phrase.
>>>>
>>>>   		bcnt -= min_t(size_t, npages << PAGE_SHIFT, bcnt);
>>>>   		mutex_lock(&umem_odp->umem_mutex);
>>>>   		for (j = 0; j < npages; j++, user_virt += PAGE_SIZE) {
>>>> -			if (user_virt & ~page_mask) {
>>>> -				p += PAGE_SIZE;
>>>> -				if (page_to_phys(local_page_list[j]) != p) {
>>>> -					ret = -EFAULT;
>>>> -					break;
>>>> -				}
>>>> -				put_page(local_page_list[j]);
>>>> -				continue;
>>>> -			}
>>>> -
>>>
>>> I think this is trying to account for compound pages. (ie page_mask could
>>> represent more than PAGE_SIZE which is what user_virt is being incrimented by.)
>>> But putting the page in that case seems to be the wrong thing to do?
>>>
>>> Yes this was added by Artemy[1] now cc'ed.
>>
>> Right, this is for huge pages, please keep it.
>> put_page() needed to decrement refcount of the head page.
> 
> You mean decrement the refcount of the _non_-head pages?
> 
> Ira
> 

Actually, I'm sure Artemy means head page, because put_page() always
operates on the head page. 

And this reminds me that I have a problem to solve nearby: get_user_pages
on huge pages increments the page->_refcount *for each tail page* as well.
That's a minor problem for my put_user_page() 
patchset, because my approach so far assumed that I could just change us
over to:

get_user_page(): increments page->_refcount by a large amount (1024)

put_user_page(): decrements page->_refcount by a large amount (1024)

...and just stop doing the odd (to me) technique of incrementing once for
each tail page. I cannot see any reason why that's actually required, as
opposed to just "raise the page->_refcount enough to avoid losing the head
page too soon".

However, it may be tricky to do this in one pass. Probably at first, I'll have
to do this horrible thing approach:

get_user_page(): increments page->_refcount by a large amount (1024)

put_user_page(): decrements page->_refcount by a large amount (1024) MULTIPLIED
                 by the number of tail pages. argghhh that's ugly.

thanks,
-- 
John Hubbard
NVIDIA

