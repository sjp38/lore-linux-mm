Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18813C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:39:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D380E218D3
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:39:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D380E218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 739248E0003; Thu, 31 Jan 2019 10:39:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E9668E0001; Thu, 31 Jan 2019 10:39:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 600388E0003; Thu, 31 Jan 2019 10:39:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0884E8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:39:23 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m19so1517839edc.6
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:39:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=b9V3qNZBACWpigEt36Bu4mxrgN6i2LWDex5NthvzWxE=;
        b=mp7kGN/RPPl22vnNGDT+X+j+HHqyo1Echm+oKSmbCal9MualDGTnw9950OaqMYHgcg
         32wDcP+2KrC/20q+GLcKX+ncqfHiKuqc4cd1BujGRN3EBi2N6hK+Q8kfiGMgKtNyA+5W
         rwQKuadLp/JeeXIbtGJYIr9oI3BXXrFrK82/UeEEWneiZCDLoVWA7O1c19eEkS+NFHin
         X2va6k4jmqU9fZU8qsmcyGZlZB2LdanA30ywR9/aND0Vq64HJ3jMqd4YLpLG5oGiRfKn
         cSG7VNk80jxFGbUn7G7TA+lzjVvj6M+RnZbEZZ7OPhs2cWP+HVKdXbbNCO4dyN/sQbPC
         f5pw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukdpbJR82TAxDqwl49EUrJsC7DHOW37tIRTulH6xaV4XrckI7l9y
	6d/fZgtvK5RK0OdKNhnCcA16f3x9TzEHx8BpegPcZfa62avvdMxGTXKJJpuQF+TwIYZK1qQpnaE
	VGBxXOuGLxOBosuemNzJGArm2kZr5ur6AdHIqSgD8PCjsO3nQhIV9pvjCVGDV6hGRIw==
X-Received: by 2002:a17:906:4b18:: with SMTP id y24mr31608719eju.23.1548949162516;
        Thu, 31 Jan 2019 07:39:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6oXod1DVaUwr/lx56sEotb8tlrqoWKJBexeA/14cFyp0dMIzXSy5btomY91vT5poS49mN6
X-Received: by 2002:a17:906:4b18:: with SMTP id y24mr31608671eju.23.1548949161590;
        Thu, 31 Jan 2019 07:39:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548949161; cv=none;
        d=google.com; s=arc-20160816;
        b=HMVGnB4v2/vrqnQx+2qC/awoeGUUS2Vmte1IR6rvctpIpU3ySO6sbq6298Q05Un6Ye
         pYHT08ZrY95OlqD+pk65CAF4W+OBbMA6JUzZmsnrlnRTCAaD7WB1yTpFYjM3uyOPYC8w
         8MqgyV3RRnqzCuPpa8cIgkwnSTf3qaq6AEld59yqp2pKxatQooTgwHuU1EOtW7A8i53f
         RGwzJfRKctHWF/ILxfTvXIHMC5RrUC8xuVhpQEAgfM1f73s5ILsnuD6q7v0M6xgwpD6H
         AhEFzvVjuD99gMwWnhBV6+zJiDgEPGhze4s6FBuKyHJ8O+YTGL20NgXFR2aaNkI+Ux37
         86sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=b9V3qNZBACWpigEt36Bu4mxrgN6i2LWDex5NthvzWxE=;
        b=QJKEtfK8ntL2S1+7KRVtgnAGGdcxkatXRm9nbROtTUzKBxfSBBsB/YnYfbRfuYodMf
         T9Lxt5h6aVxfwIceQNa7IRk+i5+61aVzGO/bdX/TXGbX8L7+37sUyfDwYeKknLc+hS8Z
         M56KRSukdbnokDVXN3EIYBCNBKVLHzbNtIsn76wpIUf7fFrbKVRzcF5XPWUCmIMSP8a1
         1xxjayW6q8mCbWuqpMYDcJuafd7YVU5lsHyMpcO5fGfxoYEWekZR2wGXTly1r8QD3qE3
         O9YhjWhi2arjzC/RtHIzDrHxqocEsILPrShbvFFSBV5PJZpQ6BSqVC94/uLUmu+A/oK/
         vm2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si2395393ejb.33.2019.01.31.07.39.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 07:39:21 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7C4BEAD5D;
	Thu, 31 Jan 2019 15:39:20 +0000 (UTC)
Subject: Re: [PATCH 20/22] mm, compaction: Sample pageblocks for free pages
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-21-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <919af440-28d2-465b-3414-bb4719b844ae@suse.cz>
Date: Thu, 31 Jan 2019 16:39:19 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190118175136.31341-21-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/18/19 6:51 PM, Mel Gorman wrote:
> Once fast searching finishes, there is a possibility that the linear
> scanner is scanning full blocks found by the fast scanner earlier. This
> patch uses an adaptive stride to sample pageblocks for free pages. The
> more consecutive full pageblocks encountered, the larger the stride until
> a pageblock with free pages is found. The scanners might meet slightly
> sooner but it is an acceptable risk given that the search of the free
> lists may still encounter the pages and adjust the cached PFN of the free
> scanner accordingly.
> 
>                                      5.0.0-rc1              5.0.0-rc1
>                               roundrobin-v3r17       samplefree-v3r17
> Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
> Amean     fault-both-3      2752.37 (   0.00%)     2729.95 (   0.81%)
> Amean     fault-both-5      4341.69 (   0.00%)     4397.80 (  -1.29%)
> Amean     fault-both-7      6308.75 (   0.00%)     6097.61 (   3.35%)
> Amean     fault-both-12    10241.81 (   0.00%)     9407.15 (   8.15%)
> Amean     fault-both-18    13736.09 (   0.00%)    10857.63 *  20.96%*
> Amean     fault-both-24    16853.95 (   0.00%)    13323.24 *  20.95%*
> Amean     fault-both-30    15862.61 (   0.00%)    17345.44 (  -9.35%)
> Amean     fault-both-32    18450.85 (   0.00%)    16892.00 (   8.45%)
> 
> The latency is mildly improved offseting some overhead from earlier
> patches that are prerequisites for the rest of the series.  However,
> a major impact is on the free scan rate with an 82% reduction.
> 
>                                 5.0.0-rc1      5.0.0-rc1
>                          roundrobin-v3r17 samplefree-v3r17
> Compaction migrate scanned    21607271            20116887
> Compaction free scanned       95336406            16668703
> 
> It's also the first time in the series where the number of pages scanned
> by the migration scanner is greater than the free scanner due to the
> increased search efficiency.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

