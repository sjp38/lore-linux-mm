Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37B96C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:49:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3817222A4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:49:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3817222A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AFF58E0002; Thu, 14 Feb 2019 05:49:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85EC58E0001; Thu, 14 Feb 2019 05:49:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74E118E0002; Thu, 14 Feb 2019 05:49:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2033E8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:49:29 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id o5so2067440wrh.7
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:49:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=1xZMdwQdfY9N0X/0yrJb3tFIpsNNrczV59J++hWZHRg=;
        b=b5YapAOHC4kiKFHthqxgiUJGb4jgMsYRrzAMl/fKECD3nyUQzyNL+r/ms7m0rEcnfl
         uUGW/Vgx6U/6ga+oF82EfikTIB627i3Yg4secFNWz+vkW1KAwdFytGIu7Iok9+PfR40i
         ojGCPTZwBseqgIKhEYk8ewHmhIT1muDpuKza4ILvtS34mJfWbwEoLw2up8hGsmoSgVLY
         9z2kjYSkNgJ5LbFs81bJzC/De4BTilPHPgUyEYfz9niuYRj4Hzl4AOtzbpBfKMrlgTr5
         6B6PY2ET0GKTX+x0rK+bfp3jst2+UZ9Leaq7V5n7PBq55knn4tKLvVNhiq54vhESr5AM
         WMvw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: AHQUAuas46M0P4GkLIcFzE6EubPh3YalPad7t+0+BnbLU9veIIdUNSlq
	zcyC3gkq+bw3/dXr6JPEpKoCa3ACa+aazR0LjOxm4FLhX7CLxLC+UZYiZZsPbFwhMGUwbxjY5WO
	SC9UpwvQWu5fjtM6VL2V3B5iNdnf5bswynD9yq+wg+DzypH3CxzLhi7J7e5T/6dQ=
X-Received: by 2002:a7b:c7c2:: with SMTP id z2mr2082242wmk.47.1550141368661;
        Thu, 14 Feb 2019 02:49:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia7lE2k1yF/dJGg+R7+VLHQ+Hh82+c9F8ANu4F6CAbmv/Kv9jTTOw1m3H+rv9eTbTmtB7VE
X-Received: by 2002:a7b:c7c2:: with SMTP id z2mr2082171wmk.47.1550141367555;
        Thu, 14 Feb 2019 02:49:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550141367; cv=none;
        d=google.com; s=arc-20160816;
        b=0XUkiuPzD+gXm+fjgpSr3OClthC0+24c7ABQh7isvkBA5i8gS05ZuNFI1t7uYCTfmt
         4YPJ0teI1BMY4Boo78dp+EXzged6eyGyxc+fZVsrxdDs1eHTv2XC0QFqG0jTRyyVTlWv
         hpKz27x5c5Tm76bPFwf+ebhJ7cvM0tz9QXtPU4M3NA5TXCFP42Y9X8zRPSZXkdKL4QkJ
         L6Xc4RUGXpvRI73vBahfvTYkkDQXzk4pN6NP4vM13nVgqkfTk8oyRsS73FvMLGHl8LLZ
         qVa5R5tVHBSsOhkoxeIw045lRZTCzCJjY4JRXlZk0nRf/C6AD1z7+pcWuWA37Exer44k
         jPCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=1xZMdwQdfY9N0X/0yrJb3tFIpsNNrczV59J++hWZHRg=;
        b=d7KZU1SLwv+XR3oWAgDHUbLKlRPguk7IrFleECizTc87RL1l84Tmww+sPTJmHmNJ7O
         BgmcL45C/DyxW7BBwoFdRD9LeihImzO4JW0ft4R1W6c4XWrWWN4JrylqPnYJdJPUSiL0
         TXM3N8foXo0Hfzkq5xEjTITxfGhDv0GWA3TkNIERuKRDNryabasg323uZgAydVJTrIpV
         8VToTZPD1bBA8bRMj4kbSarP4+rOe1lU1lVmaj6kxul9fG8ujO5lr5mXZeTT/gkJjDjw
         sSpo+Kr3PjsZ61ksCNTjMCgavFN5SRxgLn0y/lLie+cqvW89KeS2rd9z5lhmOMUXutBZ
         kv8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay8-d.mail.gandi.net (relay8-d.mail.gandi.net. [217.70.183.201])
        by mx.google.com with ESMTPS id o14si1395429wrm.294.2019.02.14.02.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 02:49:27 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.201;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay8-d.mail.gandi.net (Postfix) with ESMTPSA id 066C61BF221;
	Thu, 14 Feb 2019 10:49:19 +0000 (UTC)
Subject: Re: [PATCH v2] hugetlb: allow to free gigantic pages regardless of
 the configuration
To: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190213192610.17265-1-alex@ghiti.fr>
 <d367b5c7-eb05-6d0b-f9bf-5b3fc3f392a9@intel.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <a60ed0fd-2f2c-4789-aca0-ecf37885fb93@ghiti.fr>
Date: Thu, 14 Feb 2019 11:49:19 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <d367b5c7-eb05-6d0b-f9bf-5b3fc3f392a9@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 02/13/2019 08:30 PM, Dave Hansen wrote:
>> -#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
>> +#ifdef CONFIG_COMPACTION_CORE
>>   static __init int gigantic_pages_init(void)
>>   {
>>   	/* With compaction or CMA we can allocate gigantic pages at runtime */
>> diff --git a/fs/Kconfig b/fs/Kconfig
>> index ac474a61be37..8fecd3ea5563 100644
>> --- a/fs/Kconfig
>> +++ b/fs/Kconfig
>> @@ -207,8 +207,9 @@ config HUGETLB_PAGE
>>   config MEMFD_CREATE
>>   	def_bool TMPFS || HUGETLBFS
>>   
>> -config ARCH_HAS_GIGANTIC_PAGE
>> +config COMPACTION_CORE
>>   	bool
>> +	default y if (MEMORY_ISOLATION && MIGRATION) || CMA
> This takes a hard dependency (#if) and turns it into a Kconfig *default*
> that can be overridden.  That seems like trouble.
>
> Shouldn't it be:
>
> config COMPACTION_CORE
> 	def_bool y
> 	depends on (MEMORY_ISOLATION && MIGRATION) || CMA
>
> ?

Thanks for that,

Alex

