Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 774AAC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 09:50:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DBF020679
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 09:50:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DBF020679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E35856B0005; Tue, 11 Jun 2019 05:50:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE5776B0006; Tue, 11 Jun 2019 05:50:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAD186B0007; Tue, 11 Jun 2019 05:50:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0236B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:50:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b3so18885975edd.22
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 02:50:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=/o5L4LPCBPqe85Yg/dw7bcLQmzuIzYH92mk85SgWzd0=;
        b=bDV26mOdpVXSCiXGThzlYv2ZEzWw0uiaB6El4BSXQMvc8xVWby91xanAGPRhnALV64
         pITBJG4Y2Iw++ay+pPybYpbMgWsKZva+twhOalDtwiSLPA7QmeJ1gn1tyUuVOuK2P5kn
         SIA8dC3lXJ07WN2ptryZqac1Fs/Z5QLzwhtnBeEmwmBEFXOp4qPiFh/6EvPM6Z9zzjyc
         HCE6LlmXyXc0bfB8AKq+/WDlZST3pxggddcOW9C1WzmWxmdKgC110VR8oSqcBgjhZp7D
         6KEZf0065HKLDQIhxmuygqKT9gulDu66uV21NsZC7UudcuqMhnxkoRkgoJCQwMkRjdP/
         L3tA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXjb3kq7dBrWmB6IxRIMsqT42BwsZEARmiarXSCTa9+e4f6GaCZ
	pbWVEXXJEZ7ZLerPvrSPPE/jysR13bC0GgNvcLkf8n89cj3UZ77Zzjr/K05nHew38tq+HFv9BIr
	eqggCBW1j3HFTiEWKJRPbs3QgNrs3Xbsq3fkmTCF6v2ynMulAZ8B+Br++s/eI25m32g==
X-Received: by 2002:a50:92fc:: with SMTP id l57mr54937970eda.206.1560246613070;
        Tue, 11 Jun 2019 02:50:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyudCbaa/VQ7snHOe03l1kUNUctEFimtNALBzxCjqTEsywbGMGrnZ/i1BPOVgW1tbRUrXE9
X-Received: by 2002:a50:92fc:: with SMTP id l57mr54937889eda.206.1560246612176;
        Tue, 11 Jun 2019 02:50:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560246612; cv=none;
        d=google.com; s=arc-20160816;
        b=gZHfw6d7O8IeUO3T3UqtnlZI4w4aDEMDwGhTMpOUT4jPjc6d0TYcDu9qYP3pb59jFk
         DC4Gbwd+gqeKEGKrhp9/SJbVu2g4PsviPZ9Wwg/x5URCGw0oEYghHcsbRG3M8gvb4eSm
         /o/5kXq6FFqdwh0lMkyBYqKYofTKVhYavOu5Mw3/LQO4PEgzI7UwzbVAKVvh8NZmqk4i
         kJsI066JFRnUN5qFzvJRP9RfrAVGy/PXyK/gH8xwl4TYP8aPGyMxIDG4/O1A64sjJxnR
         qJWQDXZjALrH8F+Y/yaVlRyIEXYMeBMegzptcn9v8JQ6KTmsHItjGfLIIOuTVpr+MY3t
         8D6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=/o5L4LPCBPqe85Yg/dw7bcLQmzuIzYH92mk85SgWzd0=;
        b=NogMKVfCC3xXD+u263J9kov3qtR+NUQA1AbVLVu1Hkmu39rNofEXFq/sEGX35758oh
         NLIQIFgl76lJ0tvtPhiRc5bJ1xqVGFD+ilUqHT1zecbBDo2++Xfr/6AMQjDq6HjGP8ZZ
         vpwJof/szphovrXhAe/d9l7iCnN5Wl1gNbLHuT8huPO+N3+3iPEwk+t4Gn/GCJkiyvkS
         EfsJfMxVhJIR3NGR1h4mAlLxfpGBq244HLZfylxyo101GwOiSmvSAlISTXSECcG9LUxJ
         ITL3WPm9S9Uyqvq8ygCK/tSfBRlTa1kQyVb2wmQBHjLYcIskjByELXLZPqlUzoZ69Uhr
         UV1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id a9si10138209edn.27.2019.06.11.02.50.11
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 02:50:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 30E24337;
	Tue, 11 Jun 2019 02:50:11 -0700 (PDT)
Received: from [10.162.43.135] (p8cg001049571a15.blr.arm.com [10.162.43.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BC1593F73C;
	Tue, 11 Jun 2019 02:51:50 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] mm: hugetlb: soft-offline:
 dissolve_free_huge_page() return zero on !PageHuge
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>,
 xishi.qiuxishi@alibaba-inc.com, "Chen, Jerry T" <jerry.t.chen@intel.com>,
 "Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>, linux-kernel@vger.kernel.org
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560154686-18497-3-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <4a1ea5f4-d35d-f3a6-920c-c35520234aa3@arm.com>
Date: Tue, 11 Jun 2019 15:20:26 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1560154686-18497-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 06/10/2019 01:48 PM, Naoya Horiguchi wrote:
> madvise(MADV_SOFT_OFFLINE) often returns -EBUSY when calling soft offline
> for hugepages with overcommitting enabled. That was caused by the suboptimal
> code in current soft-offline code. See the following part:
> 
>     ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>                             MIGRATE_SYNC, MR_MEMORY_FAILURE);
>     if (ret) {
>             ...
>     } else {
>             /*
>              * We set PG_hwpoison only when the migration source hugepage
>              * was successfully dissolved, because otherwise hwpoisoned
>              * hugepage remains on free hugepage list, then userspace will
>              * find it as SIGBUS by allocation failure. That's not expected
>              * in soft-offlining.
>              */
>             ret = dissolve_free_huge_page(page);
>             if (!ret) {
>                     if (set_hwpoison_free_buddy_page(page))
>                             num_poisoned_pages_inc();
>             }
>     }
>     return ret;
> 
> Here dissolve_free_huge_page() returns -EBUSY if the migration source page
> was freed into buddy in migrate_pages(), but even in that case we actually

Over committed source pages will be released into buddy and the normal ones
will not be ? dissolve_free_huge_page() returns -EBUSY because PageHuge()
return negative on already released pages ? How dissolve_free_huge_page()
will behave differently with over committed pages. I might be missing some
recent developments here.

> has a chance that set_hwpoison_free_buddy_page() succeeds. So that means
> current code gives up offlining too early now.

Hmm. It gives up early as the return value from dissolve_free_huge_page(EBUSY)
gets back as the return code for soft_offline_huge_page() without attempting
set_hwpoison_free_buddy_page() which still has a chance to succeed for freed
normal buddy pages.

> 
> dissolve_free_huge_page() checks that a given hugepage is suitable for
> dissolving, where we should return success for !PageHuge() case because
> the given hugepage is considered as already dissolved.

Right. It should return 0 (as a success) for freed normal buddy pages. Should
not it then check explicitly for PageBuddy() as well ?

> 
> This change also affects other callers of dissolve_free_huge_page(),
> which are cleaned up together.
> 
> Reported-by: Chen, Jerry T <jerry.t.chen@intel.com>
> Tested-by: Chen, Jerry T <jerry.t.chen@intel.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
> Cc: <stable@vger.kernel.org> # v4.19+
> ---
>  mm/hugetlb.c        | 15 +++++++++------
>  mm/memory-failure.c |  5 +----
>  2 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git v5.2-rc3/mm/hugetlb.c v5.2-rc3_patched/mm/hugetlb.c
> index ac843d3..048d071 100644
> --- v5.2-rc3/mm/hugetlb.c
> +++ v5.2-rc3_patched/mm/hugetlb.c
> @@ -1519,7 +1519,12 @@ int dissolve_free_huge_page(struct page *page)
>  	int rc = -EBUSY;
>  
>  	spin_lock(&hugetlb_lock);
> -	if (PageHuge(page) && !page_count(page)) {
> +	if (!PageHuge(page)) {
> +		rc = 0;
> +		goto out;
> +	}

With this early bail out it maintains the functionality when called from
soft_offline_free_page() for normal pages. For huge page, it continues
on the previous path.

> +
> +	if (!page_count(page)) {
>  		struct page *head = compound_head(page);
>  		struct hstate *h = page_hstate(head);
>  		int nid = page_to_nid(head);
> @@ -1564,11 +1569,9 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order) {
>  		page = pfn_to_page(pfn);
> -		if (PageHuge(page) && !page_count(page)) {

Right. These checks are now redundant.

