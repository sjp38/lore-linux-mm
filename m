Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B834EC48BE3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 08:26:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88D332089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 08:26:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88D332089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 191DD8E0005; Mon, 24 Jun 2019 04:26:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1448D8E0002; Mon, 24 Jun 2019 04:26:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0318A8E0005; Mon, 24 Jun 2019 04:26:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A76258E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:26:14 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b21so19297899edt.18
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:26:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BRZq4S2DDLhQNM3xsu962oaD4iXVjqObF4JAZ5MfzjE=;
        b=Ntl3k8AhkOs0Z0GVUk/eqS39sh2LQwctox5tacWo4kvBSsNnFhtdv7RvKCHn3y2o4z
         WJfr9og6EgAgIUWtxgOrx6dsDIhbw5OoMGmReHEyb/x/A6Jnyfn9ifyxQ/xifhT6wYWO
         /HA+0KjPKbeUOYVUIIz9Cktr9zrxx0BIg7AbTPn3IF13UyHkHpzNuQcIGdWf20GC/Fi1
         hTqtb14Bqg1GwC44CZtBHGbkExM2RzZEh4KVFHuhpBABykdsDGDwDCkoEnbT4Ufrp1RN
         R7LMKWdUC0mWYPVmVLKDOSVH72Wc0OYbavmBaepTxBYs8orEwSpqa/WYuDK/yHifvpzc
         PsNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXY4KMztrh+WBLKM0cUAMx0frpTADZDu7HDZIZAxPwF+66kfSHi
	zKqe2QhRfawUWPs2xey8k/0VBOFxSWtO2RjnRwmMtavS7x14X28liyTZF7QUzX63Ed5km7f70Sz
	7holNxyQss+KxxUMIE5U5iCRYSSuLrDixEeHJkhTBbpDy8uEiWXW+VIrzKGK1TpAVTg==
X-Received: by 2002:a17:906:5243:: with SMTP id y3mr29363065ejm.88.1561364774196;
        Mon, 24 Jun 2019 01:26:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqye6v6uSew2nuoKwlqsEZIJDPYfZXiGo2iD4qsniIFBphU5wKJnCYTDZ8lzNSjaxLj4vkGg
X-Received: by 2002:a17:906:5243:: with SMTP id y3mr29363030ejm.88.1561364773533;
        Mon, 24 Jun 2019 01:26:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561364773; cv=none;
        d=google.com; s=arc-20160816;
        b=VaMxAxgp6rq+rlIAJyoU0BcLhA4zDWgv1Kn+ifgg0y1pyu4C0n05hXegfoj2AzxkJK
         2JycSIrAWfOHCWc9ksm9bGQ/QSaSK3romMuomM7rW5OMppKHLafUs88cT5SZnDyqeLZr
         yaZIlFIzlcEOdt4tUQHNwaTkZz8xUVmCn/N2MU5jTAG80eDEG2h4ro5uV2fbj4DKN2WK
         f3vm59Kc4Ah8sWXjemc72UComXTcBKY2dJmSctWLc77aP0S/9aYnKuwlCivjR7V73BUn
         mOqnf1X/E9RjXe5wT+25tqLIBjfAj2iiptaESQbE3SKxKjLjAbKH29cRJ3jAJ0s8KpaQ
         JLuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BRZq4S2DDLhQNM3xsu962oaD4iXVjqObF4JAZ5MfzjE=;
        b=BsZPlXukKrRVEi9C8bIqPEz1mJbn0GaCvPQtcpAnJoJwO0LCFpNIAzR02J0Ofn2L+8
         J1lQyy366UmIA86wNTKgend+o9nivgH2A21iMp76V5P9AnfFUd7PtkkeaP+p59sAHlTE
         btpvJYGXETgLRSzQxptPSOI1BEssn7ua3mwtUUdV1d1mFp7kEU5eveKPJk4nmDDPO2O8
         YjMiEJGeCeDuN8wkwHmx7tsNpPfg+hho3NN7gHQw/H5Stmvd7TD8YJYndFxF3z/qXO/t
         jHuk/cf8ri4d2dsfP4edG2if+eLyXlKdLg9lqfYrjWtUI3rVHkJT1QdIEw4XghVb85Z/
         e72Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 9si8956177eds.342.2019.06.24.01.26.13
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 01:26:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 81D042B;
	Mon, 24 Jun 2019 01:26:12 -0700 (PDT)
Received: from [10.162.41.123] (p8cg001049571a15.blr.arm.com [10.162.41.123])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5533C3F71E;
	Mon, 24 Jun 2019 01:26:10 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: allow gigantic page allocation to migrate
 away smaller huge page
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>,
 Oscar Salvador <osalvador@suse.de>, David Hildenbrand <david@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>
References: <1561350068-8966-1-git-send-email-kernelfans@gmail.com>
 <216a335d-f7c6-26ad-2ac1-427c8a73ca2f@arm.com>
 <CAFgQCTs14R5P7RpCTMwLCMJrGgPzbTGp4tvxCJA0kFgD8_y==g@mail.gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <5fe6bd80-7801-d81e-7a5e-a90afb697c33@arm.com>
Date: Mon, 24 Jun 2019 13:56:34 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <CAFgQCTs14R5P7RpCTMwLCMJrGgPzbTGp4tvxCJA0kFgD8_y==g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/24/2019 11:40 AM, Pingfan Liu wrote:
> On Mon, Jun 24, 2019 at 1:16 PM Anshuman Khandual
> <anshuman.khandual@arm.com> wrote:
>>
>>
>>
>> On 06/24/2019 09:51 AM, Pingfan Liu wrote:
>>> The current pfn_range_valid_gigantic() rejects the pud huge page allocation
>>> if there is a pmd huge page inside the candidate range.
>>>
>>> But pud huge resource is more rare, which should align on 1GB on x86. It is
>>> worth to allow migrating away pmd huge page to make room for a pud huge
>>> page.
>>>
>>> The same logic is applied to pgd and pud huge pages.
>>
>> The huge page in the range can either be a THP or HugeTLB and migrating them has
>> different costs and chances of success. THP migration will involve splitting if
>> THP migration is not enabled and all related TLB related costs. Are you sure
>> that a PUD HugeTLB allocation really should go through these ? Is there any
> PUD hugetlb has already driven out PMD thp in current. This patch just
> want to make PUD hugetlb survives PMD hugetlb.

You are right. PageHuge() is true only for HugeTLB pages unlike PageTransHuge()
which is true for both HugeTLB and THP pages. So the current code does migrate
the THP out in order to allocate a gigantic HugeTLB. While here just wondering
should not we exclude THP as well unless it supports ARCH_HAS_THP_MIGRATION.

