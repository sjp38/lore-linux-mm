Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 132EFC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 22:36:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB62B218D9
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 22:36:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB62B218D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60ABD8E0003; Tue, 26 Feb 2019 17:36:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 593B78E0001; Tue, 26 Feb 2019 17:36:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45DD08E0003; Tue, 26 Feb 2019 17:36:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00F1A8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 17:36:24 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id s22so10856259plq.7
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 14:36:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q7WKQ1uwCL5jlfbpTKmdgD2l6rk8KA/V5CGF5nMGw80=;
        b=lFAzZlu1Am0gm8Adp+nl15Zn6TcgrProxt/QTFAOcUrb1lPKGQZjtORlnmTjEDvCQT
         SY+8XfMXX19IvZSnpBcKQzoShKw4ga4P/uIp9niEnnBjGiOslgQt3Iu43Gu34s6PO9PR
         MBn8SvEoiiBk6yP3A6xrJACjXJQNqsgA8oTVGoaldOXQ/Wd+2icAPfry7YJGXDfXaBuh
         Lm5JuHJOhTyM0JTZn2Ii7tkyyTimcB21NOQyRxBCVaCq9rsvqMJxkzU1BvS73XsAxsUd
         LJAgifME08GfA30+dqTDFCX0wOmo0iPeubMXwBk2+KND8rDKqvn8+LAyEpQ/YXuA0YzM
         1K1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYo6yA8t+yJ1hJL4AaSbjVG0Tyxqez67nAdg9MSt+KPrxUZMLhr
	V0I4vXLkrPjOYSe7lYHg5LqUUB1XIDqeYmxXFsBQvM6520OOvUz0keGJ5aXyANIJhataCNzeYM7
	xi9VdahRvi4kNl+Q5pnVOzHhArc701aZdli60f0xSZPSYyvGfa1yTWBOuBgpoKH0SQQ==
X-Received: by 2002:a62:1551:: with SMTP id 78mr7807411pfv.45.1551220583659;
        Tue, 26 Feb 2019 14:36:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYdZniAvgR3bxdB1lnQi4e2jSPF7fbM4MmHeR/8GNC0QxXeAH1NvgPpnM55JG6NpDy17Jvb
X-Received: by 2002:a62:1551:: with SMTP id 78mr7807340pfv.45.1551220582588;
        Tue, 26 Feb 2019 14:36:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551220582; cv=none;
        d=google.com; s=arc-20160816;
        b=VjFcegIJuz416nPXepUSiSYAGVQCZ70dbcurpCCyzKb8fBmiDtHfDr2LWePcMNlbFn
         2nInI7h7wXShByIMtp0ZQ3/wiDSttXdg8JXXsF0x0C6aJHMt7Du4jWqtpFD4bMnCt3ni
         hiVXcyPV23Fn85YLXYld3ravdVjnwrk++vG3QhFE0x5s/04ryBzYTBsHnax2DA7DaJYK
         uQcfwTCXDEjBvKmHqChsFDsPsfbyp60DFwOqr1gB3evzm1DJ3L4+eHdRJ1rfnPaQWAIj
         al2SlpjWZZChvFTuAJz8BdQ/mdVgTS6TGNAA3T9Py+UnyReTxP731lnAskafeF/hTxcS
         FaFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=q7WKQ1uwCL5jlfbpTKmdgD2l6rk8KA/V5CGF5nMGw80=;
        b=osASjNbJgKnceujVK6Y5gXmIziqNUKzsSeEVagA5QsLC0XDrwsEmLW4ymvETYZ7KH+
         DSGgivktPwqlMbQPr0zJ/od1J3PtCKY/bI6Xc/BXdz0s1MNkZAchh3l1cEXhd98VZV60
         /D81t41K041KzGRses971TSCZQSInxEjO8sPJjJCl4h3MLVlnJr/5l1YVmgAzReR9BWY
         vGbKgpfhbaXUVvV6eDbTM5Pz3m5HCdmtJu7K2KmJYziLDWjpQrt8XT0t44ChaSlnB41H
         7RjEs01u4snEVS6zMugP0xNE+lZp61aGAYM3SG7dFrs9bbZhU5QUwMwQqt1BiTuS5kVE
         p1Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y16si4505893pfa.282.2019.02.26.14.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 14:36:22 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id ACC427B88;
	Tue, 26 Feb 2019 22:36:21 +0000 (UTC)
Date: Tue, 26 Feb 2019 14:36:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: David Rientjes <rientjes@google.com>, Jing Xiangfeng
 <jingxiangfeng@huawei.com>, mhocko@kernel.org, hughd@google.com,
 linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli
 <aarcange@redhat.com>, kirill.shutemov@linux.intel.com,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
Message-Id: <20190226143620.c6af15c7c897d3362b191e36@linux-foundation.org>
In-Reply-To: <e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
References: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com>
	<388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
	<alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
	<8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
	<13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
	<alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
	<5C74A2DA.1030304@huawei.com>
	<alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
	<e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> The number of node specific huge pages can be set via a file such as:
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
> When a node specific value is specified, the global number of huge
> pages must also be adjusted.  This adjustment is calculated as the
> specified node specific value + (global value - current node value).
> If the node specific value provided by the user is large enough, this
> calculation could overflow an unsigned long leading to a smaller
> than expected number of huge pages.
> 
> To fix, check the calculation for overflow.  If overflow is detected,
> use ULONG_MAX as the requested value.  This is inline with the user
> request to allocate as many huge pages as possible.
> 
> It was also noticed that the above calculation was done outside the
> hugetlb_lock.  Therefore, the values could be inconsistent and result
> in underflow.  To fix, the calculation is moved to within the routine
> set_max_huge_pages() where the lock is held.
> 
> ...
>
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2274,7 +2274,7 @@ static int adjust_pool_surplus(struct hstate *h,
> nodemask_t *nodes_allowed,

Please tweak that email client to prevent the wordwraps.

> +	/*
> +	 * Check for a node specific request.  Adjust global count, but
> +	 * restrict alloc/free to the specified node.
> +	 */
> +	if (nid != NUMA_NO_NODE) {
> +		unsigned long old_count = count;
> +		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
> +		/*
> +		 * If user specified count causes overflow, set to
> +		 * largest possible value.
> +		 */
> +		if (count < old_count)
> +			count = ULONG_MAX;
> +	}

The above two comments explain the code, but do not reveal the
reasoning behind the policy decisions which that code implements.

> ...
>
> +	} else {
>  		/*
> -		 * per node hstate attribute: adjust count to global,
> -		 * but restrict alloc/free to the specified node.
> +		 * Node specific request, but we could not allocate
> +		 * node mask.  Pass in ALL nodes, and clear nid.
>  		 */

Ditto here, somewhat.

The old mantra: comments should explain "why", not "what".  Reading the
code tells us the "what".

Thanks.

