Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BB6AC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 14:52:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3E9620869
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 14:52:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3E9620869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A68F8E0002; Thu, 31 Jan 2019 09:52:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0561B8E0001; Thu, 31 Jan 2019 09:52:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAF0E8E0002; Thu, 31 Jan 2019 09:52:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7728E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 09:52:13 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t2so1419884edb.22
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:52:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=PB/ZhEE/njpeWywvK5pPhRT9RGHOmRWGcvYMiiFnw2Q=;
        b=iwVFaS5cLPYrnuvgcqgZlBytc+GnRRKL4hmfJ13J9qQg/j+0ncK337TtnHBHUAqhkk
         2pXcDu3pw972SaYZbrNvYjNfZ8xOSvgxeP3fH4Xdsv6PN6RMp8U6JjfACDAtZF8Eh27g
         J1QlUzzNTKgrq8H/CmAXfnVXfIMloo9Vc8bjHOYBQHpsh1unU/mNiCt6XhsRwSY02k8c
         aGvSLcT+/ahMNmvibEJ3+nM7Stjmg/AAHO5A8jbZqfDcTVwgX3Apeu6piifxs0Dl/L+/
         SmQuvLzvHiQybUCejc1NnCjmpsMiAuDxfqPZVqHG+3W3VLgBIF8w80Z031PVa/OAtZV4
         yIYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukeH3as2/wze1zInuAOgKtr2Ox5WMN9BFcxwnUGrwvUaCqI7oxLU
	5RsJjc6doTYE1BC5Hm894Rr30TnquX6SedoSbPE+7Tv5ktLGOQYIz1CP5vOXr3jnWpa5lgdS78m
	6Nl3+Niot3OCxMc+5qaVU2fyTG70DyMNP8K0Ty6+G4Fz+GffieiYSrxd4RyfamRqzaw==
X-Received: by 2002:a50:9ead:: with SMTP id a42mr35439619edf.291.1548946333099;
        Thu, 31 Jan 2019 06:52:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5ryfjK3oVcVtQpoKEaEl98IjhrwRu1MenBNkeqA6cXWGv7791WcSWn3fQ0b9C1f5h6k64r
X-Received: by 2002:a50:9ead:: with SMTP id a42mr35439552edf.291.1548946332036;
        Thu, 31 Jan 2019 06:52:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548946332; cv=none;
        d=google.com; s=arc-20160816;
        b=EOr7OWxXlrKbosO+lPKubiRz9z2QOaYX+7pQXAl56CaTTYlQUGQkqzuZctqFUyOSfK
         SO4HOTJyqJ0zzUD7xP98cQ+fxJzGP6x9pNB9ugP/qf1uXkGENgNbVGnCexSVRUbi5bDU
         iYVtOMMHI9M28Qwh8NDmGRQjY3zQXQ447utTEQghBBcR2S8HkuZfnnk4LS1uw4OI3pRQ
         7dyBIjc6xoooRegKaq1kR9ktP1E4xnCRCnzRJzhBTJNr6cyu9/07Js4nSa89RiG0QSB1
         C46mnlcuLwy+jhMPU9rz6j1uGiy1c8YlUzHG8GmAGUp9RMa5DIe4PV4ne3kCyChQokLb
         cMJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=PB/ZhEE/njpeWywvK5pPhRT9RGHOmRWGcvYMiiFnw2Q=;
        b=v2omL1s8leQguywu0sJQTe5EhNrDPKZoiVv6YcmEYfKpim1TIQPK2MYZboUYP/0aEf
         X1EOodVhvbiMk2o3g/yXkTN2uJnwJpSGktd+gYMjvk53WPPXB1qP6YIDgrZsEXnfsEcf
         sQmAGW2/hmCzJfPh8j0+1YAmHz4mEADMQZnftJMHwjP9xykRHESa4KAIMBOXB5Gx2OnG
         BOTvFAehP50AgfPC7tqNBvbcbc3hvxyWpr4hEhpIZ/1oEQ0taPh6kWUIpQA9L8vLW1YV
         By0qDpdOLs35XjlVLe4K+O+uv8Q7IVSWbnCeeq/BjpeXrGwNZTK6bNaWgQsAm1G9++ux
         JojA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si450764edt.45.2019.01.31.06.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 06:52:12 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3A6BEAD14;
	Thu, 31 Jan 2019 14:52:11 +0000 (UTC)
Subject: Re: [PATCH 11/22] mm, compaction: Use free lists to quickly locate a
 migration target
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-12-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <81e45dc0-c107-015b-e167-19d7ca4b6374@suse.cz>
Date: Thu, 31 Jan 2019 15:52:10 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190118175136.31341-12-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/18/19 6:51 PM, Mel Gorman wrote:
> Similar to the migration scanner, this patch uses the free lists to quickly
> locate a migration target. The search is different in that lower orders
> will be searched for a suitable high PFN if necessary but the search
> is still bound. This is justified on the grounds that the free scanner
> typically scans linearly much more than the migration scanner.
> 
> If a free page is found, it is isolated and compaction continues if enough
> pages were isolated. For SYNC* scanning, the full pageblock is scanned
> for any remaining free pages so that is can be marked for skipping in
> the near future.
> 
> 1-socket thpfioscale
>                                      5.0.0-rc1              5.0.0-rc1
>                                  isolmig-v3r15         findfree-v3r16
> Amean     fault-both-3      3024.41 (   0.00%)     3200.68 (  -5.83%)
> Amean     fault-both-5      4749.30 (   0.00%)     4847.75 (  -2.07%)
> Amean     fault-both-7      6454.95 (   0.00%)     6658.92 (  -3.16%)
> Amean     fault-both-12    10324.83 (   0.00%)    11077.62 (  -7.29%)
> Amean     fault-both-18    12896.82 (   0.00%)    12403.97 (   3.82%)
> Amean     fault-both-24    13470.60 (   0.00%)    15607.10 * -15.86%*
> Amean     fault-both-30    17143.99 (   0.00%)    18752.27 (  -9.38%)
> Amean     fault-both-32    17743.91 (   0.00%)    21207.54 * -19.52%*
> 
> The impact on latency is variable but the search is optimistic and
> sensitive to the exact system state. Success rates are similar but
> the major impact is to the rate of scanning
> 
>                                 5.0.0-rc1      5.0.0-rc1
>                             isolmig-v3r15 findfree-v3r16
> Compaction migrate scanned    25646769          29507205
> Compaction free scanned      201558184         100359571
> 
> The free scan rates are reduced by 50%. The 2-socket reductions for the
> free scanner are more dramatic which is a likely reflection that the
> machine has more memory.
> 
> [dan.carpenter@oracle.com: Fix static checker warning]
> [vbabka@suse.cz: Correct number of pages scanned for lower orders]
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Small fix below:

> -/* Reorder the free list to reduce repeated future searches */
> +/*
> + * Used when scanning for a suitable migration target which scans freelists
> + * in reverse. Reorders the list such as the unscanned pages are scanned
> + * first on the next iteration of the free scanner
> + */
> +static void
> +move_freelist_head(struct list_head *freelist, struct page *freepage)
> +{
> +	LIST_HEAD(sublist);
> +
> +	if (!list_is_last(freelist, &freepage->lru)) {

Shouldn't there be list_is_first() for symmetry?

> +		list_cut_before(&sublist, freelist, &freepage->lru);
> +		if (!list_empty(&sublist))
> +			list_splice_tail(&sublist, freelist);
> +	}
> +}
> +
> +/*
> + * Similar to move_freelist_head except used by the migration scanner
> + * when scanning forward. It's possible for these list operations to
> + * move against each other if they search the free list exactly in
> + * lockstep.
> + */
>  static void
>  move_freelist_tail(struct list_head *freelist, struct page *freepage)
>  {

