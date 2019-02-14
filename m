Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD870C10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 03:41:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 685EE222B6
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 03:41:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 685EE222B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B54488E0002; Wed, 13 Feb 2019 22:41:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B02218E0001; Wed, 13 Feb 2019 22:41:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F11F8E0002; Wed, 13 Feb 2019 22:41:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47FFB8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 22:41:42 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f11so1895111edi.5
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:41:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0Sqbp0acYxkkmUMZczKAGPCmfwBf7ep1Ohyv9I4ScuM=;
        b=G7q68O3Otx1G9uQPF8tYAYjLvrYsvlE/9ubFkNnlaLc55sU00X0sW7o6RTSvvB+Qqu
         8ya4yc7CbTH4YuWg/u+5GsMAENpDhzB+VOJon/rKaqYkvww3MtGWgUVdTbCGbBOu0PTc
         vHI0TYcWSHn4jTHVmq61O5hyl9sqYeYnofkQ/fdZGdwirymrysNI3Mk5y99ZdOj0Mz+2
         Zey94D3m2LtO35WbZrs49Ia/uTQGUNeLRlJ521tjFOc4vpezm4WXVhjcmqKQv40zBxOo
         s8XlsMvevHv4GdN6QKeGiK5hjdovLf/+k0X6GAO5XaU9isPOtjBcGliF5CYrxVqVJcO9
         MskA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAub9huqtbcM7O7LdKA8TZDclFartvodWIvbsOMbjrb3XFATIk9IT
	4zrvKxuTmFtguBoxUghLDMuGk9Em8vFPIgSWqkQ+Z/PM/06G6/sW2CWU0PdVc1GSggj8Tqofmjp
	sg2gb//B+iluqZCxB6qDnwN1tWdDz2jMleH8Wt0C8wc3xwhF/dBs20Bwmf2GZNgDjew==
X-Received: by 2002:a17:906:3391:: with SMTP id v17mr1063075eja.101.1550115701682;
        Wed, 13 Feb 2019 19:41:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYn3WGw9aowiJ5gM3ynmayZYJVC3z0go0Nrgw6XHBuHAB/xP2cO64lrny4Px5YYKyZjY/B0
X-Received: by 2002:a17:906:3391:: with SMTP id v17mr1063018eja.101.1550115700756;
        Wed, 13 Feb 2019 19:41:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550115700; cv=none;
        d=google.com; s=arc-20160816;
        b=YkSh7GQmFYO9SHQ6Mt9k7DZutHGz8s1ByEJNWKAE5K0KuL9RhRFzVwj1zThclMuWmj
         KQzqD+J/8H0F2h4OnTlBdtTe2A4WBca4I3mnDonzjVASnWca27W7rRDWU8/t3GBu0AHW
         3DfrlTAGzlrm8/hM9yOLtVqSfDaClfJYEdsvMzNolGc7WCLQnn0+ebeCC/edp8mPct8p
         VC31vpCUDShjHuQntsGDbOdAvfdZJVx8IkV9WuH8ESQvktB7UbFSfNLDVSvLkqmTLCSs
         I2EiDo26uClZnb93JTM5op+V5CiSvLkvkHR3A2JjCCVjwxh9tLp+k4tp2pMnOmryIB7d
         jCog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0Sqbp0acYxkkmUMZczKAGPCmfwBf7ep1Ohyv9I4ScuM=;
        b=cwMOfkAGpz0CXTcnqe/1FAK8aTyCJRxi+lTATb1c4rABvh+JqA+TUTkOnlJmBepyk3
         8zaNeiZ4xujQJ8tuVnqhvnm01mxONhy7Dp/gjIaELsldijuVpsrz/weUZZeViLq8G+8C
         euCWlHuctQZMoO5MoHzyLXCiFf0w0QbW1MRuBJ6H6NqKv2AuBu6+cD9WjCizvc5VEh6b
         W81oyWCN4PK1H9h0+PKlT2EAhfqeMdXQdhHHkgHxUZ8W8nxw8XDdiIcE0xZEQgLnyOe0
         75BIsX6qdvDXk6C/fI6QlhbfrD73RUoTbG4jaO8vqyGBtmqnTEGVvoXlCJCa0TlPkJ4t
         i/ZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i5si554103eds.261.2019.02.13.19.41.40
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 19:41:40 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1E79D80D;
	Wed, 13 Feb 2019 19:41:39 -0800 (PST)
Received: from [10.162.42.113] (p8cg001049571a15.blr.arm.com [10.162.42.113])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C89953F589;
	Wed, 13 Feb 2019 19:41:36 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] Non standard size THP
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
 lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Vlastimil Babka <vbabka@suse.cz>
References: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
 <20190212083331.dtch7xubjxlmz5tf@kshutemo-mobl1>
 <282f6d89-bcc2-2622-1205-7c43ba85c37e@arm.com>
 <20190213133827.GN4525@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <3088cb22-a304-16d8-d97a-5e1e840a7f55@arm.com>
Date: Thu, 14 Feb 2019 09:11:36 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190213133827.GN4525@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/13/2019 07:08 PM, Michal Hocko wrote:
> On Wed 13-02-19 18:20:03, Anshuman Khandual wrote:
>> On 02/12/2019 02:03 PM, Kirill A. Shutemov wrote:
>>> Honestly, I'm very skeptical about the idea. It took a lot of time to
>>> stabilize THP for singe page size, equal to PMD page table, but this looks
>>> like a new can of worms. :P
>>
>> I understand your concern here but HW providing some more TLB sizes beyond
>> standard page table level (PMD/PUD/PGD) based huge pages can help achieve
>> performance improvement when the buddy is already fragmented enough not to
>> provide higher order pages. PUD THP file mapping is already supported for
>> DAX and PUD THP anon mapping might be supported in near future (it is not
>> much challenging other than allocating HPAGE_PUD_SIZE huge page at runtime
>> will be much difficult). Around PMD sizes like HPAGE_CONT_PMD_SIZE or
>> HPAGE_CONT_PTE_SIZE really have better chances as future non-PMD level anon
>> mapping than a PUD size anon mapping support in THP.
> 
> I do not think our page allocator is really ready to provide >PMD huge
> pages. So even if we deal with all the nasty things wrt locking and page
> table handling the crux becomes the allocation side. The current
> CMA/contig allocator is everything but useful for THP. It can barely
> handle hugetlb cases which are mostly pre-allocate based.

I understand the point for > PMD size. Hence first we can just narrow the
focus on contiguous PTE level huge pages which are < PMD but could offer
THP benefits on arm64 for 64K config page sizes.

> 
> Besides that is there any real world usecase driving this or it is
> merely "this is possible so let's just do it"?

64K config arm64 kernel is mostly unable to use THP at PMD level of 512 MB.
But it should be able benefit from THP if we have support at cont PTE level
of 2MB which is way less than 512MB.

