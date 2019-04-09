Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E27EC282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:08:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36DEE2133D
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:08:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36DEE2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E5606B0006; Tue,  9 Apr 2019 05:08:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 795B96B0007; Tue,  9 Apr 2019 05:08:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6855D6B0008; Tue,  9 Apr 2019 05:08:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0966B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 05:08:16 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id r84so7164268oia.9
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 02:08:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=jiBy5RRRTqg5OdOcbnJEnDi6Tzr+NTnRMya9wFlIzJc=;
        b=Bwy5g1HEYLuaT3+LflNT7QdU5CAoVeXHi85FI/ShI2GDPs9RDK7a6IsCBh2rbIrTbS
         vdS1d9lm8zLNHjdcjQzTFpedY4FBVNX82rpd3+2JwstePONUTRzFr5As0JSwhKMYWyPb
         ylQPXWqdpbjLiLA9LSBB3QUMoYIP6ws6yeVNmiZSu79Z5oCrmvX9JvUl8IOT4geWc4Pa
         LG1u6pmaBrMVzz7WyGOnQH2Hxl6IT4UhocofSAzL908S7kAm7v+xlvay7iSRGSkNJbdj
         mnYXPbhSzw6gE/vvUmQyCc0w331ttAxqiKHP26tl5Q1v3C1nm6KPiQDtkQCUk9YEPtln
         uHZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUaMzXEkCZjIuEPb+tSAhERK5ARZb8YGUzTadbroI2xEa8UofBE
	v+uMoRYmlplPexHySTBKHVk3WvDzxoe9vCbfEltX0y6r5fUzsVeXa5yIFP09MvRc+MsttmbEeWM
	1hjgvWx5bvG/N2qD9LgIe69tToYmWb4YgWXOr1a+mlM+GNix+HKmCh1roT+h0C9y9Ug==
X-Received: by 2002:a05:6830:144c:: with SMTP id w12mr12015090otp.192.1554800895797;
        Tue, 09 Apr 2019 02:08:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwU9c260oI6XrjHLdi/yE0ggMYfOpFtrOQXy81vGyxwFZCRP8plb3Tje1xtzwelcBtlBLcq
X-Received: by 2002:a05:6830:144c:: with SMTP id w12mr12015036otp.192.1554800894961;
        Tue, 09 Apr 2019 02:08:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554800894; cv=none;
        d=google.com; s=arc-20160816;
        b=iSU68gSr8ueiEeSVly5sH/FKJGgQ3QpSo8KI8rrejVbFMQNfdonjuEm8Bi/D27mWrj
         04ENDLpMrEZ04UAPwhj4N2k9sVxyTV+8uoiIxIwtzU1ae8034S4CR12J9nXQQz3pgxTb
         tU7yLLj6MOS4ebEMg02HO8gslfkGyWI9eMlPcAMzLC7TVxKZjbIB+TbvmZ9lKMsplQn0
         BzJy8ACws3gTDnGSQPByLtu2i8ihBduoX53p6ndeYd7i+FdQDPv5ezQHTL6i47to1tYt
         HUlV/RaqUfTaURiXCPYqVQJ/oQ4XN6ug8mJXFqDQlCMooJqEkcwMEp5n2IS3RjtTCLAX
         ADYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=jiBy5RRRTqg5OdOcbnJEnDi6Tzr+NTnRMya9wFlIzJc=;
        b=gdS0AxN4ZXA1zukgpiWIR0kAUrxSAJeqXC6fjSoYAV9BC6w722dqFBJKzkIyS1uinW
         TwKFjD5Rq0P8AyvGkxg4a7MN6Cq+V88PYRubqVm/mwVqufTcMR+pHiA+VlMzsPHLLiM4
         t6OMaW1mAc32Q6ROWx05xS3aypeZnPYVrUtZRmW39RRA3Saj/+HQfP3nxT4yRAf8alzQ
         96OQALu9MR6MitMV8Ulghf5AwiulOw2tfggFBBmSMunD4gYF3DJxBcME+sU9vMT38c5u
         LgRncPLNCS0hDecIDZy2kQLt7bxeMsiiib9+cUI/jSdNJiwqNSEZTFjb8C9v+AGzLvbH
         QpqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id k11si16969483otk.162.2019.04.09.02.08.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 02:08:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 90249B177B81D34F2DA8;
	Tue,  9 Apr 2019 17:08:09 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.408.0; Tue, 9 Apr 2019
 17:08:01 +0800
Subject: Re: [PATCH 0/3] support reserving crashkernel above 4G on arm64 kdump
To: Bhupesh Sharma <bhsharma@redhat.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>, <rppt@linux.ibm.com>,
	<ard.biesheuvel@linaro.org>, <takahiro.akashi@linaro.org>
References: <20190403030546.23718-1-chenzhou10@huawei.com>
 <49012d55-2020-e2ac-1102-59a5f3911a29@redhat.com>
CC: <wangkefeng.wang@huawei.com>, <kexec@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-arm-kernel@lists.infradead.org>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <573f2b4b-9a55-d9b2-6de5-0b60eba0b211@huawei.com>
Date: Tue, 9 Apr 2019 17:07:59 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <49012d55-2020-e2ac-1102-59a5f3911a29@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Bhupesh,

On 2019/4/9 13:20, Bhupesh Sharma wrote:
> Hi Chen,
> 
> Thanks for the patchset.
> 
> Before I review the patches in detail, I have a couple of generic queries. Please see them in-line:
> 
> On 04/03/2019 11:05 AM, Chen Zhou wrote:
>> When crashkernel is reserved above 4G in memory, kernel should reserve
>> some amount of low memory for swiotlb and some DMA buffers. So there may
>> be two crash kernel regions, one is below 4G, the other is above 4G.
>>
>> Crash dump kernel reads more than one crash kernel regions via a dtb
>> property under node /chosen,
>> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.
>>
>> Besides, we need to modify kexec-tools:
>>    arm64: support more than one crash kernel regions
>>
>> Chen Zhou (3):
>>    arm64: kdump: support reserving crashkernel above 4G
>>    arm64: kdump: support more than one crash kernel regions
>>    kdump: update Documentation about crashkernel on arm64
>>
>>   Documentation/admin-guide/kernel-parameters.txt |   4 +-
>>   arch/arm64/kernel/setup.c                       |   3 +
>>   arch/arm64/mm/init.c                            | 108 ++++++++++++++++++++----
>>   include/linux/memblock.h                        |   1 +
>>   mm/memblock.c                                   |  40 +++++++++
>>   5 files changed, 139 insertions(+), 17 deletions(-)
> 
> I am wondering about the use-case for the same. I remember normally fedora-based arm64 systems can do well with a maximum crashkernel size of <=512MB reserved below the 4G boundary.
> 
> So, do you mean that for your use-case (may be a huawei board based setup?), you need:
> 
> - more than 512MB of crashkernel size, or
> - you want to split the crashkernel reservation across the 4GB boundary irrespective of the crashkernel size value.
> 
> Thanks,
> Bhupesh
> 
> 
> .
> 

I do this based on below reasons.

1. ARM64 kdump support crashkernel=Y[@X], but now it seems unusable if X is specified above 4GB.
2. There are some cases we couldn't reserve 512MB crashkernel below 4G successfully if there is
no continous 512MB system RAM below 4GB. In this case, we need to reserve crashkernel above 4GB.
3. As the memory increases, the bitmap_size in makedumpfile may also increases, we need more memory
in kdump capture kernel for kernel dump.

Thanks,
Chen Zhou


