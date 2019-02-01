Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D250C282DB
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:58:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3515821902
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:58:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3515821902
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C71B68E0003; Fri,  1 Feb 2019 09:58:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFAB78E0001; Fri,  1 Feb 2019 09:58:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9C3D8E0003; Fri,  1 Feb 2019 09:58:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6958E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 09:58:23 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so2942650edc.6
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 06:58:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=gsEtjM55k7xtDSDIybAY6hyEqYQBgSdrviFl4r9SCQM=;
        b=J3W5gKbPB0Jaiqsqtf79iMaXxaLjZlkw8VkgpEjWtwOqYVJbzfsQLffrdIYqdHvnJT
         TYIhh8A607M89Mefu5f8BPb0/Ndf8UJcqKOqbtWRHpcEgTMr0MQJpZ5nljWvbjN5Nf8F
         tcnNdm8rNBG8J4pLA+Q2waMZSEyCcIflQ2iZvgE9Nmb4sRpQT8yHIGBDdClxFywP4Iet
         oryXD6SKEsrvuNz0YzGIEacEZYU6tkDetMiQ9hCSDjdLYwmmt8Ak2nuAnkoi8cxVwh11
         DGYOMOgzEOwORhsg/ij2+PP4RhM5/bzDdTw0KOtxB4EGBt1pb2slWrz6nk7b+TaA3raa
         Nx7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukciGM9oMcewj2/BmLKXvh0jAGqJknapf7cdk8el+uROZJhrBfeL
	EEBoBojbCJdLJLcd/AlqzxtyI7to4x1cPgjTF4+fhlpduTsHPIBbfFTaSC6Lu+8obb6LjZAXTAR
	A8RXoHIV3RdiF3sbp+QAtieWkZB2L1HWVdkt69XjGn7GkL9RG/JDrsfWM1C2WrlBepQ==
X-Received: by 2002:a17:906:3591:: with SMTP id o17mr33347097ejb.226.1549033102845;
        Fri, 01 Feb 2019 06:58:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5iAEOTWuyHfbwgCbfr5aQGv7HhQoa5pyBKMuJuz0ZKQfX9su+uiZSSRx7hJgw4TLRQJ+mz
X-Received: by 2002:a17:906:3591:: with SMTP id o17mr33347047ejb.226.1549033101945;
        Fri, 01 Feb 2019 06:58:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549033101; cv=none;
        d=google.com; s=arc-20160816;
        b=yizkbCM3ydKAjSvSztZ6XaOkF8bex/EUiNxYDsb/jMZR9F0Ai8AMfG2yS3x/3lvN1Z
         4ZhnOF64grmg+rFZjO22pAY1TeiK9LNojkyDjCcLC6sOxGxgJNyVcN8+xc+AtsVrFd5I
         glRstJMWoJvMdkCvq4M9znHnG9GavMSONCcLSYDVEniM34g75mqzy3hLubJ5w5f07IgQ
         DkEWgs3mib6FAvUqF0GOG2iKFiESg1oaapvs8u2svFD7FJwRfQP5yE2u6v31t+143L+b
         zW3wv7XX1iUkFH1TB7JndjxdrvVgvaQcMKugH/0Q7cJLa2zBJ8R/bCX/tWEbasOwP564
         uo3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=gsEtjM55k7xtDSDIybAY6hyEqYQBgSdrviFl4r9SCQM=;
        b=ui+Af9Ck0IjHgIARxPfStNY8hdG7Wm+4E44J8ZqYTKwCkndDWwStD2hD9xch4dpVO9
         LA1jVKEgKeUjOViJrJdDN/u177roUtwh/2NeBRf3kFHzmblTs7xmteXvvtE3xwZqGjTH
         9hwFDdAgFZHFhKEF87Sx51rd7h0S4Vp1lV0cwMY8JGdBU2WVAj0k8v3KpMJ67IjED1Qj
         PONebPPeNeZWP9g67xm2OoQbftjzQxTavsyLbbI1roATa8FG0dFDyWsPgDtotRuPFhgP
         Q+hY6/+CQqpZsE9i8/E+Qs7WwIIf7m//EcVsntTiRkMWT7S/BrGLRyIwGRKw4Iuz+Ndl
         K3lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j16si1467375ejq.208.2019.02.01.06.58.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 06:58:21 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E3D74AC90;
	Fri,  1 Feb 2019 14:58:20 +0000 (UTC)
Subject: Re: [PATCH 11/22] mm, compaction: Use free lists to quickly locate a
 migration target
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 David Rientjes <rientjes@google.com>, Andrea Arcangeli
 <aarcange@redhat.com>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-12-mgorman@techsingularity.net>
 <81e45dc0-c107-015b-e167-19d7ca4b6374@suse.cz>
 <20190201145139.GI9565@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <cb0bae2e-8628-1378-68a1-9da02a94652e@suse.cz>
Date: Fri, 1 Feb 2019 15:58:19 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190201145139.GI9565@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/1/19 3:51 PM, Mel Gorman wrote:
> On Thu, Jan 31, 2019 at 03:52:10PM +0100, Vlastimil Babka wrote:
>>> -/* Reorder the free list to reduce repeated future searches */
>>> +/*
>>> + * Used when scanning for a suitable migration target which scans freelists
>>> + * in reverse. Reorders the list such as the unscanned pages are scanned
>>> + * first on the next iteration of the free scanner
>>> + */
>>> +static void
>>> +move_freelist_head(struct list_head *freelist, struct page *freepage)
>>> +{
>>> +	LIST_HEAD(sublist);
>>> +
>>> +	if (!list_is_last(freelist, &freepage->lru)) {
>>
>> Shouldn't there be list_is_first() for symmetry?
>>
> 
> I don't think it would help. We're reverse traversing the list when this is
> called. If it's the last entry, it's moving just one page before breaking
> off the search and a shuffle has minimal impact. If it's the first page
> then list_cut_before moves the entire list to sublist before splicing it
> back so it's a pointless operation.

Yeah I thought the goal was to avoid the pointless operation, which is
why it was previously added as "if (!list_is_last())" in
move_freelist_head(). So in move_freelist_head() it would have to be as
"if (!list_is_first())" to achieve the same effect. Agree that it's
marginal but if that's so then I would just remove the checks completely
(from both functions) instead of having it subtly wrong in one of them?

