Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EED5FC282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:45:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B682C218D3
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:45:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B682C218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5393B8E0003; Thu, 31 Jan 2019 10:45:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E9B08E0001; Thu, 31 Jan 2019 10:45:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 401B58E0003; Thu, 31 Jan 2019 10:45:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EDC3D8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:45:18 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so1508213edd.11
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:45:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=jSnMb0O3TSIII+gonLQVTeCZYVLEnoRLnxt8QA8ahec=;
        b=D5sdmCIvZuFPE8Lt+kaawZtIAiex8Oq/SXXhCoy6LhbUWhUNT1OI9pjTeKOJp5bJ95
         fTBk2bZdrkvVnfOFQgjHoqhKCpXJnC6H0AM0+rAml4rTp46qNtOFN5hl3LAvDSTUz6uR
         JvYv1qPdx9JfALhKi13Pe7HqWyaOGHDUnRHrRCEhTgzvVp8ZNAyxpEUgM+C2T9+8MBMJ
         LHfIAF0sDfxQCZRx6kSAy+xTBSpaLs4rxDwetr0Ym4bGSlCh6Ga67nzG07HW3ruVB/IS
         S8kcJX+IjvMbvucc1WxcXPbNHMVRYDmZUSf453GIxPtUBTGv9HUsgjmNL1cfaFtHLEC8
         q45Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUuke7gx9zUxT7HsYbtcu78AoU/+2IfhlqIMye2o+pGMvnMUcLd9z6
	Equ2IcV2waLoXPStMVUl0P/zBBVl1OcU60yI3Rl91jJuvt90NyrH7t3gSmLLA1iFFU+GcdFFnbQ
	qM3bcxKDvRN5uvcO2evQJV8sCWQID9bHJ0qdouZlq/OJDWtpJgzQuaTxafNqWZ2s7Ew==
X-Received: by 2002:a50:c089:: with SMTP id k9mr27390829edf.89.1548949518550;
        Thu, 31 Jan 2019 07:45:18 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7zcrLUsrWxnMfxpiPnQnzLuqyc5gOnUlGKvuuoj4xjes73GKaGSqxj7QyfQ75GtGf9CklQ
X-Received: by 2002:a50:c089:: with SMTP id k9mr27390773edf.89.1548949517709;
        Thu, 31 Jan 2019 07:45:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548949517; cv=none;
        d=google.com; s=arc-20160816;
        b=WsUoYgLehDsReoF94ROLw58nLB2GqavTlagtTtX3eqoqAT481O5OuzkBat0rBnXi6j
         XCpmtbqZuT+oaOnCBhRNaYfh4s7A7Zy3zb6o0Mzs7aB5i6+I9cXG4VfVNKZcA9vNN8Sp
         1bibnOzR309Ij6E0Jb9tsw6EEtGxPf7MzWKAgZHNvESax/XdZmA8Dw5yyFkkCrkLB8pC
         Wlt3fkfLocS2m0cac0/GgLCY8O7bIrJXKUjjXhdBudLLC048YFyZDGnywApOOwnMS7CN
         MaS4sKLFU6oMzn+39mDE2aqHDdYOzFwZgXn2A7E12L9JaV+LKfB5Gwh5OPxyA/6Vxexj
         fzvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=jSnMb0O3TSIII+gonLQVTeCZYVLEnoRLnxt8QA8ahec=;
        b=coazp7cdjlNHwPi2g0a1ULXZaawo5J48/xgRz+nbsN97Y0d+7xYT2bOywlxLeFQWIH
         hlDdDnWXEoJJm5ekdWAG/VHLZ9MGEXC8qnX0lX98sxzOYt8ondPdMrxZOj3LC1Z1z/tF
         J/vbWKIIso0wYwBisIg/LynT78Mk67bVLXdG5oTaPHPrLS9gPa0pdDX9//Ohd3JIkl/u
         jd4FhWyCO5nVpFjckeGaRSlgiHlGWsqonVqP9vsLzF9nSoCT6yBKbrRB95emsnZpARZP
         gXFYbDK0XzR/Pm5Ss/FFXl91xJpVBH509d4SugfOV2lkalISdvFuyBnX0+OA3cVrBIrv
         BeGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15si2489786ejd.9.2019.01.31.07.45.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 07:45:17 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E8B16B0B9;
	Thu, 31 Jan 2019 15:45:16 +0000 (UTC)
Subject: Re: [PATCH 21/22] mm, compaction: Be selective about what pageblocks
 to clear skip hints
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-22-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <9318efb7-cf20-b87d-9038-27406925b161@suse.cz>
Date: Thu, 31 Jan 2019 16:45:16 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190118175136.31341-22-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/18/19 6:51 PM, Mel Gorman wrote:
> Pageblock hints are cleared when compaction restarts or kswapd makes enough
> progress that it can sleep but it's over-eager in that the bit is cleared
> for migration sources with no LRU pages and migration targets with no free
> pages. As pageblock skip hint flushes are relatively rare and out-of-band
> with respect to kswapd, this patch makes a few more expensive checks to
> see if it's appropriate to even clear the bit. Every pageblock that is
> not cleared will avoid 512 pages being scanned unnecessarily on x86-64.
> 
> The impact is variable with different workloads showing small differences
> in latency, success rates and scan rates. This is expected as clearing
> the hints is not that common but doing a small amount of work out-of-band
> to avoid a large amount of work in-band later is generally a good thing.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

