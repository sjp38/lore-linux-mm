Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F4229C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 14:34:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAA602084F
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 14:34:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="C2N6Tpw8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAA602084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 488676B0005; Fri, 13 Sep 2019 10:34:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 438AE6B0006; Fri, 13 Sep 2019 10:34:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 326D16B0007; Fri, 13 Sep 2019 10:34:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id 0A42D6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 10:34:13 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8FB1C8243773
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 14:34:12 +0000 (UTC)
X-FDA: 75930142344.03.debt17_2481ff809024c
X-HE-Tag: debt17_2481ff809024c
X-Filterd-Recvd-Size: 3988
Received: from ste-pvt-msa1.bahnhof.se (ste-pvt-msa1.bahnhof.se [213.80.101.70])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 14:34:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTP id E72E63F919;
	Fri, 13 Sep 2019 16:34:08 +0200 (CEST)
Authentication-Results: ste-pvt-msa1.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b=C2N6Tpw8;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from ste-pvt-msa1.bahnhof.se ([127.0.0.1])
	by localhost (ste-pvt-msa1.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Vw_hi0fk4Ref; Fri, 13 Sep 2019 16:34:08 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTPA id 8EF763F8F3;
	Fri, 13 Sep 2019 16:34:03 +0200 (CEST)
Received: from localhost.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id B5C68360195;
	Fri, 13 Sep 2019 16:34:02 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1568385242; bh=BvEPU9tGdG9Bhovi4Q0bbdW07y3/r6iPP1tQbS5B3Dg=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=C2N6Tpw8BPIFywM28iULu9uVwEykXdq683K3MIwLno68ImFSJZcnvmXSvgNcJIYdy
	 fs4C//xIQbV9rfjigSnkNMrqRAk1fZNIyu8n47xwzegCFDax40hgZFLFcTfQR1uDnD
	 U7ABEyDM6piI7eeUK+RBjldeM/OcAfSWfj7G4gTg=
Subject: Re: [RFC PATCH 3/7] drm/ttm: TTM fault handler helpers
To: Hillf Danton <hdanton@sina.com>, Thomas Hellstrom <thellstrom@vmware.com>
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org, pv-drivers@vmware.com,
 linux-graphics-maintainer@vmware.com,
 Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>,
 Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@surriel.com>,
 Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>,
 Huang Ying <ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
 jglisse@redhat.com, christian.koenig@amd.com,
 Christoph Hellwig <hch@infradead.org>
References: <20190913093213.27254-1-thomas_os@shipmail.org>
 <20190913134039.3164-1-hdanton@sina.com>
From: =?UTF-8?Q?Thomas_Hellstr=c3=b6m_=28VMware=29?= <thomas_os@shipmail.org>
Organization: VMware Inc.
Message-ID: <f26f6096-8d11-82e4-390c-d110af8fdc49@shipmail.org>
Date: Fri, 13 Sep 2019 16:34:02 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190913134039.3164-1-hdanton@sina.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/13/19 3:40 PM, Hillf Danton wrote:
> On Fri, 13 Sep 2019 11:32:09 +0200
>>   	err = ttm_mem_io_lock(man, true);
>> -	if (unlikely(err != 0)) {
>> -		ret = VM_FAULT_NOPAGE;
>> -		goto out_unlock;
>> -	}
>> +	if (unlikely(err != 0))
>> +		return VM_FAULT_NOPAGE;
>>   	err = ttm_mem_io_reserve_vm(bo);
>> -	if (unlikely(err != 0)) {
>> -		ret = VM_FAULT_SIGBUS;
>> -		goto out_io_unlock;
>> -	}
>> +	if (unlikely(err != 0))
>> +		return VM_FAULT_SIGBUS;
>>
> Hehe, no hurry.

Could you be a bit more specific?

Thanks,

Thomas



>
>> @@ -295,8 +307,28 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *vmf)
>>   	ret = VM_FAULT_NOPAGE;
>>   out_io_unlock:
>>   	ttm_mem_io_unlock(man);
>> -out_unlock:
>> +	return ret;
>> +}
>> +EXPORT_SYMBOL(ttm_bo_vm_fault_reserved);



