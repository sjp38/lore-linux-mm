Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47E87C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 17:10:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0946820863
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 17:10:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0946820863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D9308E0097; Fri,  8 Feb 2019 12:10:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 985C28E0002; Fri,  8 Feb 2019 12:10:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84E578E0097; Fri,  8 Feb 2019 12:10:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0828E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 12:10:50 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so1216981edt.20
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 09:10:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xv4bLs4jQbgLjELQBtmZlYnOmldc8GheTjNK/Dbqtbo=;
        b=uBVP55gSikf3T7UWnARuMW/YGqs/Sla2YlnadQIRpitH3TDbi6AO4nlxTlhMi/5WW1
         N6Bai+0ioZRiTuS7JTi1NEqOTrONfG3HjhLBRlDK0rFm2KVO3nWE9c+lwdlW+XAMARUV
         m30tdUine2AWDIEOcHXlEvP11aeiE2E99wm0MoZINFsfafRU9SniQQHPy8idzbxlqTWu
         S6KZuUAu5wIclqV2mRmn1cm6RE4FwLxi5ZWVTEX8zkJ8+hBC+HYyJCtg4DRalJrkTQA0
         du3pLSKUJl89lemnbNkWYz1oGdq25nZljPe+Aa1d1fnep3khVhhTRQFQlBo2azyuWEfE
         9BuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuYqxENuYfHQq6tLbw9VvfhzPuAbn556EWNJ6fPaZNE3oWv7JFgB
	E89VQIvI4Lgr75rYB0OBGuMPVJuGch2cUMiqvr9uSXLa87XL055c2bx+knOOgY7ifOSkMM15dmi
	mM9smy7QAGFiKpTxO3c8ANS2JB/G7EDE4TczDKj2fZ4CIPI0B6fmYkZPzECvSFMNZpQ==
X-Received: by 2002:a17:906:7345:: with SMTP id h5mr2193475ejl.208.1549645849695;
        Fri, 08 Feb 2019 09:10:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbAbVKl47Z80PetkQgvBGbYhYX+qEjXiKOBMb0ns1OUDxgxX9zZWFvNGyNFCP4tXGwfcg+y
X-Received: by 2002:a17:906:7345:: with SMTP id h5mr2193423ejl.208.1549645848704;
        Fri, 08 Feb 2019 09:10:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549645848; cv=none;
        d=google.com; s=arc-20160816;
        b=0d6ymWZSiCZ0EAUHm8bBrCPtTSTxJ3G2xQT4xkGAzfzR7wuW1XZZMkk30tJuRgpPbT
         5sqx7uAeI5fPosOgKVxCJuQQVHc8EzZcAqh6cHDMYJdH+FfGFYvi1E43GKxIn8jd7l+m
         uNrWLx94cbaJozHik1WMEwGlhVa98StnSjcV4JHPvK4rPlfC5+Y/kpy/9mVaVl1aGYSW
         iq+TvFMMnrxwvYYVmvdDgFdxqXKjgzU5heypyWVvoLc9qWhQdRw3wXwXiF/mJVTTYkPM
         0FaFz9BBd/2Nzg4t9jEhjzanxV5vqtplbfAphTw03V1QOnx+I3/w4OwWaSq4Dn8CXPcL
         gUMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xv4bLs4jQbgLjELQBtmZlYnOmldc8GheTjNK/Dbqtbo=;
        b=oVQv0RqUvFtPrakEBZ76Dn3q/OfUp5dWrRDbzjt+1lPcCjDVAH92Bbvn+B6q6EQbEg
         Em2x/SQSODsd59u65cc25BJ/v2VpJ8CbMzKVUC6gAYdjoxVwCjZdqY0EklGslt1KW9Y/
         3MyE8im+xY6Zx7aYnSPAGMOaEzP5C33lj0lBLdUs8eNvOMGc7xvgBdocpNTMvLidnn77
         Las5s7nMwQ60t8jUj3Xg6WAfEGuCHbTynKWAcvI3slh/cWS/6kwWQRTNbfq+dj79ribN
         Iye0URR4eBnOlOL3M4lqOiX/4gkwUNt/2JY3Sj0ex9FXwAPHGOTzKD2qdYctDk56EreA
         CeOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a24si1326084edm.339.2019.02.08.09.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 09:10:48 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 047B9AF46;
	Fri,  8 Feb 2019 17:10:48 +0000 (UTC)
Subject: Re: [PATCH 09/22] mm, compaction: Use free lists to quickly locate a
 migration source
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-10-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7b698aca-bd47-7d5c-a114-145b813b7bdb@suse.cz>
Date: Fri, 8 Feb 2019 18:10:47 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190118175136.31341-10-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/18/19 6:51 PM, Mel Gorman wrote:
> The migration scanner is a linear scan of a zone with a potentiall large
> search space.  Furthermore, many pageblocks are unusable such as those
> filled with reserved pages or partially filled with pages that cannot
> migrate. These still get scanned in the common case of allocating a THP
> and the cost accumulates.
> 
> The patch uses a partial search of the free lists to locate a migration
> source candidate that is marked as MOVABLE when allocating a THP. It
> prefers picking a block with a larger number of free pages already on
> the basis that there are fewer pages to migrate to free the entire block.
> The lowest PFN found during searches is tracked as the basis of the start
> for the linear search after the first search of the free list fails.
> After the search, the free list is shuffled so that the next search will
> not encounter the same page. If the search fails then the subsequent
> searches will be shorter and the linear scanner is used.
> 
> If this search fails, or if the request is for a small or
> unmovable/reclaimable allocation then the linear scanner is still used. It
> is somewhat pointless to use the list search in those cases. Small free
> pages must be used for the search and there is no guarantee that movable
> pages are located within that block that are contiguous.
> 
>                                      5.0.0-rc1              5.0.0-rc1
>                                  noboost-v3r10          findmig-v3r15
> Amean     fault-both-3      3771.41 (   0.00%)     3390.40 (  10.10%)
> Amean     fault-both-5      5409.05 (   0.00%)     5082.28 (   6.04%)
> Amean     fault-both-7      7040.74 (   0.00%)     7012.51 (   0.40%)
> Amean     fault-both-12    11887.35 (   0.00%)    11346.63 (   4.55%)
> Amean     fault-both-18    16718.19 (   0.00%)    15324.19 (   8.34%)
> Amean     fault-both-24    21157.19 (   0.00%)    16088.50 *  23.96%*
> Amean     fault-both-30    21175.92 (   0.00%)    18723.42 *  11.58%*
> Amean     fault-both-32    21339.03 (   0.00%)    18612.01 *  12.78%*
> 
>                                 5.0.0-rc1              5.0.0-rc1
>                             noboost-v3r10          findmig-v3r15
> Percentage huge-3        86.50 (   0.00%)       89.83 (   3.85%)
> Percentage huge-5        92.52 (   0.00%)       91.96 (  -0.61%)
> Percentage huge-7        92.44 (   0.00%)       92.85 (   0.44%)
> Percentage huge-12       92.98 (   0.00%)       92.74 (  -0.25%)
> Percentage huge-18       91.70 (   0.00%)       91.71 (   0.02%)
> Percentage huge-24       91.59 (   0.00%)       92.13 (   0.60%)
> Percentage huge-30       90.14 (   0.00%)       93.79 (   4.04%)
> Percentage huge-32       90.03 (   0.00%)       91.27 (   1.37%)
> 
> This shows an improvement in allocation latencies with similar allocation
> success rates.  While not presented, there was a 31% reduction in migration
> scanning and a 8% reduction on system CPU usage. A 2-socket machine showed
> similar benefits.
> 
> [vbabka@suse.cz: Migrate block that was found-fast, some optimisations]
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

With the followup fix,

Acked-by: Vlastimil Babka <Vbabka@suse.cz>

