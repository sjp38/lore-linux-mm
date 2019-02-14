Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49022C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 06:04:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08A4C21934
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 06:04:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08A4C21934
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8754A8E0003; Thu, 14 Feb 2019 01:04:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FC1A8E0001; Thu, 14 Feb 2019 01:04:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C3B88E0003; Thu, 14 Feb 2019 01:04:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED508E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:04:15 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id a21so720343eda.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 22:04:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=837dtVyVb/c7rG7Ym8sNaGnnqVuoGEAD+GZyAZhmZ5w=;
        b=cCBn7QwvHRxDqvbv6vReQZZ2mL70Kgvr/sVMjN4RaZ4jpowVebkZiybNfkTwAQ5uJu
         MczQrTt/39ekvO4QvKHaHntfIrQnZmPX8lkpF3eVMRCNZJUGz+Da8RQaaRoRr0HPGK5J
         qXWZrOAgLBBRYefXdsY0hzZ7glPP89dzQjfYfQ2KUj4Nzz7CWTGRhDAEFKnG9fOL0M87
         2HHuwKqB2M8GgM0767BEnTcpSrV9qjzYtVS4TxbPBlULdS0+BApHluxhATWxQcFV8GVW
         ThZbd3/hjfRBlmeol/BBgyYbi2dEGzbSKHtLolTlzSYvdbp9hVq6HIyl2uVG8dhEIBKX
         gukQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAubAElLMtzDqj6ECOnTFOw+3ND1yJq88YRFzf7Gee8nYyTTb9kVu
	3fsJTYajg5bT0mpjUFcrYCsKqqiFKbgsMSRusL/iLZxz/T95+HVrAlhYZKlnQccFkXmui88GUxb
	RTPCACKOoUbKC6NPFqearY0wK2P83wY1BvMxxMXsD50+/KZHOr0tcWTl5RcEnJfI3mg==
X-Received: by 2002:a17:906:4bd9:: with SMTP id x25mr1487234ejv.171.1550124254518;
        Wed, 13 Feb 2019 22:04:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYlpdjnZJvd+yMihmuCkCmWTXkZalu/H1+V5T8gyEvd0VFQoRdefGkulhro449TT4idWx+O
X-Received: by 2002:a17:906:4bd9:: with SMTP id x25mr1487192ejv.171.1550124253533;
        Wed, 13 Feb 2019 22:04:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550124253; cv=none;
        d=google.com; s=arc-20160816;
        b=Aw7odYDi5VE1BAV4YJt04+egoalZvwbU20/1itvNkgCTTsgsXrExcnAwBcUk+heobO
         DgcU3uM6/PrbkzeNL7AMI5AGwNv7Q3tYL3F8uKusMYrw0+t6IQy6D64eA/L/0CsRnpyk
         hZA5uOnQDA3H+hN+p0CzwjvmZkuump0Rc3IVAjCVNPf3zNjq4CBncU05g9+Y1XUy/Avr
         msXN4FZbeXpd71vT7hHx5HAYNtuNTTvlpzHL5lxeLh2Cr+LURSuF5OWH8Nd3yFH/NWY3
         5CdRPCBoJznh7NBAcNB5NIhLwBP43+nEfXHtK9ICA/d7TgRScX5ePIEiVgL7xPT5Gb4Q
         iVvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=837dtVyVb/c7rG7Ym8sNaGnnqVuoGEAD+GZyAZhmZ5w=;
        b=hsJuy/WWdc+B3SOHQZmBfUhX0VJxoVA6U41kjImO7AAfSay4p7NQb4xvfsb38Hb2Dy
         UQgTsgwTgLKBQxX6a+ugkJqE4gMbwbT5jIM+XAR7h1EPnaBj9kSSeAZecg0bDoIrTzM4
         ekIR/ym2yY1xpZuvxzvQPRKBF2WOCp4OZ11lH6bdju6pSKUfNkeKJZSjM7C2gQyudl6T
         wF7jhBoH/Wc+aFQ8Z/bO+2nmkp99UsM3KzkkFe+o9iwfvqU9TCXEesdDh9AkMQ3Irnna
         I7OEuTQlVhFqgHzCS87iSf3Bjy/zRNUX63g6FR0UL05eomeMBYNnt64NyovWLJDTi2Kc
         tM5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l19si316603edc.437.2019.02.13.22.04.13
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 22:04:13 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4DA6C80D;
	Wed, 13 Feb 2019 22:04:12 -0800 (PST)
Received: from [10.162.42.113] (p8cg001049571a15.blr.arm.com [10.162.42.113])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BBC313F675;
	Wed, 13 Feb 2019 22:04:09 -0800 (PST)
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
To: Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name,
 kirill.shutemov@linux.intel.com, vbabka@suse.cz, will.deacon@arm.com,
 dave.hansen@intel.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190213153819.GS4525@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
Date: Thu, 14 Feb 2019 11:34:09 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190213153819.GS4525@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/13/2019 09:08 PM, Michal Hocko wrote:
> On Wed 13-02-19 11:21:36, Catalin Marinas wrote:
>> On Wed, Feb 13, 2019 at 01:36:27PM +0530, Anshuman Khandual wrote:
>>> Setting an exec permission on a page normally triggers I-cache invalidation
>>> which might be expensive. I-cache invalidation is not mandatory on a given
>>> page if there is no immediate exec access on it. Non-fault modification of
>>> user page table from generic memory paths like migration can be improved if
>>> setting of the exec permission on the page can be deferred till actual use.
>>> There was a performance report [1] which highlighted the problem.
>> [...]
>>> [1] http://lists.infradead.org/pipermail/linux-arm-kernel/2018-December/620357.html
>>
>> FTR, this performance regression has been addressed by commit
>> 132fdc379eb1 ("arm64: Do not issue IPIs for user executable ptes"). That
>> said, I still think this patch series is valuable for further optimising
>> the page migration path on arm64 (and can be extended to other
>> architectures that currently require I/D cache maintenance for
>> executable pages).
> 
> Are there any numbers to show the optimization impact?

This series transfers execution cost linearly with nr_pages from migration path
to subsequent exec access path for normal, THP and HugeTLB pages. The experiment
is on mainline kernel (1f947a7a011fcceb14cb912f548) along with some patches for
HugeTLB and THP migration enablement on arm64 platform.

A. [Normal Pages]

nr_pages	migration1 	migration2	execfault1	execfault2	

1000 		7.000000	3.000000	24.000000	31.000000
5000 		38.000000 	18.000000	127.000000	153.000000
10000 		80.000000 	40.000000	289.000000	343.000000
15000		120.000000	60.000000	435.000000	514.000000
19900 		159.000000	79.000000	576.000000	681.000000

B. [THP Pages]

nr_pages	migration1 	migration2	execfault1	execfault2

10 		22.000000	3.000000	131.000000	146.000000
30 		72.000000	15.000000	443.000000	503.000000
50 		121.000000	24.000000	739.000000	837.000000
100 		242.000000	49.000000	1485.000000	1673.000000
199 		473.000000 	98.000000	2685.000000	3327.000000

C. [HugeTLB Pages]

nr_pages	migration1 	migration2	execfault1	execfault2

10		97.000000 	79.000000	125.000000	144.000000
30 		292.000000 	235.000000	408.000000	463.000000
50 		487.000000 	392.000000	674.000000	777.000000
100 		995.000000 	802.000000	1480.000000	1671.000000
130 		1300.000000 	1048.000000	1925.000000	2172.000000

NOTE:

migration1: Execution time (ms) for migrating nr_pages without patches
migration2: Execution time (ms) for migrating nr_pages with patches
execfault1: Execution time (ms) for executing nr_pages without patches
execfault2: Execution time (ms) for executing nr_pages with patches

