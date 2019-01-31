Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C127C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:11:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44BE82085B
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:11:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44BE82085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E77DD8E0006; Thu, 31 Jan 2019 11:11:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E25578E0003; Thu, 31 Jan 2019 11:11:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D19818E0006; Thu, 31 Jan 2019 11:11:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 758388E0003
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:11:06 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o21so1568550edq.4
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:11:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=3A9N4rgzDXUymfSjQeAImdz+wIjmslTXXVhxRazOPf4=;
        b=hX8j3GniNTfGuhsSVXRZ758m1tsRX1+MnURNcJ04dhyWxAUSlk1/3wskf9Yy/+ULC8
         YQ1vbkz6Xx1PZBmvwTBUIt2C4RqA5/jVmzlak3i5pAP4IvcXUgzGGgZPiA+nepSFx8e8
         a9mq6sBJDv+S/d/cz02jO5czynCOeIe9SvJPuSrg34vN/hukKRb2uGjJfEQRl0H05wPY
         Vti5XeDQtuwXDAEaR5DCj2xapoOXROMas0B+NkF7HSDfpF924tgtBvjDwQJSvTmoPJUB
         7iJu0rb3eaVOIlnDeRZIhVepC+VJ+FIKNSfBswU5PbBPciXzYpTEdQZtWDJx0LRxoSZo
         vJCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukcAL4jTsP6+d7Hxde3fHZOvLcWJhdPeV6Wf1ckn9O57/Jz+jSZQ
	ETgDfE7kJDRpdtWVqz2tD+PYn7ty2q7MG0Kx24FV2a1XUTXIBd284hrGfYeDgFjpM40WMJ/cpF1
	L0qQ1GFDn7UVPOMs9eruIuk87Z9CdS9FXvqSfLZpmXioUpcOsXj/nRy+Xvl0X0EVx+Q==
X-Received: by 2002:a17:906:4a0c:: with SMTP id w12mr27125761eju.240.1548951065988;
        Thu, 31 Jan 2019 08:11:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5iC32Yu8a8ALvoZTIz045RsPbxLFtlzdUo06rf5f5YcRGcS2iYSUpRgZpJ6D5ySiZztE0Q
X-Received: by 2002:a17:906:4a0c:: with SMTP id w12mr27125698eju.240.1548951065002;
        Thu, 31 Jan 2019 08:11:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548951064; cv=none;
        d=google.com; s=arc-20160816;
        b=ypatwnamQYsy0Vp4M+KaebfbdYmaZfM5pU7C4bHy+xy585LQVSNFAx6lq36G4FdjPg
         9RNC+EVqRa+cXHTsuRuTSpwQL+mNb35KX3yf0ZQ7wrD/Z/NqFPKbW6KeIwVPi5ZcPNCx
         tZJkXWABLZkkV+gthZCDlDVLABMbHGif4QT+AU/+2F8yS4l3w6H0bOrG82robm8C2c/Z
         xudI8uMn4GJ1jnVQ8sxYvI5MEbs/Q3QRSramm7hIcRIW7evMpFkA2B79y7QSop1js8sl
         W+MWL0Bi5H2tdmqmRc7fPnpYeKtCZEiIQedjv9F85acVKAurzKzsSSIhpVdEcg4NbfFc
         r4Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=3A9N4rgzDXUymfSjQeAImdz+wIjmslTXXVhxRazOPf4=;
        b=uXQVlFYhZep6Ep12nSNnbE3x2kBDrpP8W3KXSpRecfpQ/EHAuEzhk9RKk0DrxpfwY0
         OZjoYRJFni6VE29hGhO9S2NcZztQY2mtP1xPtPhaO2hEjaEWyoWRjoeAasF4fgtTJxVT
         U+/dZdARFJOh4z3Pw9ohMh+V7q8nhPbwiXkl5mYNu9QcgA3x0Im3hnu8UG27HvqsYWhC
         Q+DUTQevWiFWC5SsNjY5fdxbcC1mTdWnNALAloBmtm73IDPv5T9KDibykZ2Cd+3BwwyH
         gH7MTpIYS+pifCmr7PP299GJC/g/HvWA8cfu9EqDTsFu9OhH+/q+72C2o8kvHjbs7pIx
         ZlxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x32si2592580edc.425.2019.01.31.08.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 08:11:04 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8D640B01C;
	Thu, 31 Jan 2019 16:11:04 +0000 (UTC)
Subject: Re: [PATCH 22/22] mm, compaction: Capture a page under direct
 compaction
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-23-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <2124d934-0678-6a4b-9991-7450b1e4e39a@suse.cz>
Date: Thu, 31 Jan 2019 17:11:04 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190118175136.31341-23-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/18/19 6:51 PM, Mel Gorman wrote:
> Compaction is inherently race-prone as a suitable page freed during
> compaction can be allocated by any parallel task. This patch uses a
> capture_control structure to isolate a page immediately when it is freed
> by a direct compactor in the slow path of the page allocator. The intent
> is to avoid redundant scanning.
> 
>                                      5.0.0-rc1              5.0.0-rc1
>                                selective-v3r17          capture-v3r19
> Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
> Amean     fault-both-3      2582.11 (   0.00%)     2563.68 (   0.71%)
> Amean     fault-both-5      4500.26 (   0.00%)     4233.52 (   5.93%)
> Amean     fault-both-7      5819.53 (   0.00%)     6333.65 (  -8.83%)
> Amean     fault-both-12     9321.18 (   0.00%)     9759.38 (  -4.70%)
> Amean     fault-both-18     9782.76 (   0.00%)    10338.76 (  -5.68%)
> Amean     fault-both-24    15272.81 (   0.00%)    13379.55 *  12.40%*
> Amean     fault-both-30    15121.34 (   0.00%)    16158.25 (  -6.86%)
> Amean     fault-both-32    18466.67 (   0.00%)    18971.21 (  -2.73%)
> 
> Latency is only moderately affected but the devil is in the details.
> A closer examination indicates that base page fault latency is reduced
> but latency of huge pages is increased as it takes creater care to
> succeed. Part of the "problem" is that allocation success rates are close
> to 100% even when under pressure and compaction gets harder
> 
>                                 5.0.0-rc1              5.0.0-rc1
>                           selective-v3r17          capture-v3r19
> Percentage huge-3        96.70 (   0.00%)       98.23 (   1.58%)
> Percentage huge-5        96.99 (   0.00%)       95.30 (  -1.75%)
> Percentage huge-7        94.19 (   0.00%)       97.24 (   3.24%)
> Percentage huge-12       94.95 (   0.00%)       97.35 (   2.53%)
> Percentage huge-18       96.74 (   0.00%)       97.30 (   0.58%)
> Percentage huge-24       97.07 (   0.00%)       97.55 (   0.50%)
> Percentage huge-30       95.69 (   0.00%)       98.50 (   2.95%)
> Percentage huge-32       96.70 (   0.00%)       99.27 (   2.65%)
> 
> And scan rates are reduced as expected by 6% for the migration scanner
> and 29% for the free scanner indicating that there is less redundant work.
> 
> Compaction migrate scanned    20815362    19573286
> Compaction free scanned       16352612    11510663
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Nit below:

...

> @@ -819,6 +870,7 @@ static inline void __free_one_page(struct page *page,
>  	unsigned long uninitialized_var(buddy_pfn);
>  	struct page *buddy;
>  	unsigned int max_order;
> +	struct capture_control *capc = task_capc(zone);
>  
>  	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
>  
> @@ -834,6 +886,12 @@ static inline void __free_one_page(struct page *page,
>  
>  continue_merging:
>  	while (order < max_order - 1) {
> +		if (compaction_capture(capc, page, order, migratetype)) {
> +			if (likely(!is_migrate_isolate(migratetype)))

compaction_capture() won't act on isolated migratetype, so this check is
unnecessary?

> +				__mod_zone_freepage_state(zone, -(1 << order),
> +								migratetype);
> +			return;
> +		}
>  		buddy_pfn = __find_buddy_pfn(pfn, order);
>  		buddy = page + (buddy_pfn - pfn);
>  

