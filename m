Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9196AC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 03:14:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 325322075B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 03:14:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="V/Q0c0q2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 325322075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B90828E0004; Tue,  5 Mar 2019 22:14:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3FFF8E0001; Tue,  5 Mar 2019 22:14:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0A868E0004; Tue,  5 Mar 2019 22:14:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 779448E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 22:14:32 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id q193so8714443qke.12
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 19:14:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3lMsB7qZB/O5v3pKAJRA9qupz0TGiaJREmmxihEt0HY=;
        b=GEXnXc3HXpgWD2nc9HyqEOLS29nVdTh+ww+qYWSwfVIove4TnjgrYuYhz8NRxSLomC
         sxJ0qXxQSz44LVQZ7iTrVI1QNxnSTJbwe7aMLtwMaMUbbN4ZahiNG84YdttMSC5p6tKx
         oI5IjfIk8fewzGMKfcUetnt2hW3Wj/mr4BBQBBTxy50rc4XlFF8KFHGPd/bV31NGMTlG
         +h7Oc96OMR7vC2I8tt9wi9OtTlxaWANd/jYcT9f13PhCHYlVQzFbxDufG6Fas5uC5Z4c
         a4uUcfxc1O/dtg6m9VqkVVKdk15WFBnYOWs25cc819AQAff7NnNsymnRiwGXw1RQgJwZ
         uEQw==
X-Gm-Message-State: APjAAAUMSv0ymQiuh412U++S/jNoJrMKaLUppFKx8PIBy8vBNX0fi3GV
	xq86jSFfQnWcGE2flWtc+ECkCy2UTPO+NTOAQN25oRdlfuCa7lqtFYWTzHsoUFacVFEqFWGY6Ro
	d2CojUyebYkdQYbZUOMk+7X14gtLiRpMc10hcT8abmcQS4aMzpP8ngq4HMtTVhXWCb8JP2O58Zq
	uEhwqWqjEq2bjnR+GHHJgoRrg/2hoHJiuhxNKedkVL49BFTLGREQ/4GceFbsW2mUYSgW9OyeMxq
	VLqwX19UFkU3F4sq6mfgZici7ZW5+klZLEuog2Z+Ly+EaUytRvPSMt41JtNCgrqVgftbUGNo4Lb
	mK03TJKxRNhRTWy99dApHQQNT1UIANKI5YQn9yWwbV87+R6SbvgQaGMVtN4x9GtCxGFAcnNRSUe
	B
X-Received: by 2002:ac8:2d0b:: with SMTP id n11mr3961799qta.143.1551842072195;
        Tue, 05 Mar 2019 19:14:32 -0800 (PST)
X-Received: by 2002:ac8:2d0b:: with SMTP id n11mr3961771qta.143.1551842071617;
        Tue, 05 Mar 2019 19:14:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551842071; cv=none;
        d=google.com; s=arc-20160816;
        b=xK6Nu8Nu0uURHXX3xPeMKEhvCiXULaOFuflyo6FY2+4O/qitmuIa2AE01OhG2NBOz8
         qu255ffo05vPJuxUQnqfmHUo/RwoLi43A8hnFoasRrGpVbto2O2ukju4TtYQTrIMwuMO
         sy5S1g6t5GXJ4tvhcbH39IhY2u5UjnDReo9qbw/RbmRNiMjRP+bKGSywUB0PHEPKe/6p
         ZY0XwAhMbzklzXKcYCx/LdcC6zGri++cZ85El5SkAQxNS8LDhVcUlkWtacjC7Y8+03uH
         eZyDjEZW1ZCn9Wd+7q26XxyCk4DDmL/i4ZkwCFYLU4FsnP6stQvHwf2u9vw3MFSmEr/w
         RJiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=3lMsB7qZB/O5v3pKAJRA9qupz0TGiaJREmmxihEt0HY=;
        b=dFl1zn61GUpJ4GRyV8mb10GjPFN4gSFdc81YtYronsbfLQamoj0q0Vo2yb6ITSwPHc
         kd9oKn0KJQVwdNLMTIjTkBW+gStQNi5CQ9DwwfvgQedIVYTPUK43KuDjNGqDb/a3bHYy
         pbetEhKno00C7fA4MOcs0FCQHtm3dYkbWzeceixHVViPOMJP2WTiynHcuQCLL6SysNq6
         HEjd5ed/QsOYwhtY8HasKf1Aug4E7gYePlCXmgHulqNVx4qmFuDWnH4dql039PYdTRVj
         1hqCMA4kE5QHEx/gr1ou6pN6OJPWpJXvuaOCTmauei/dh3oBI1hH50YG9PV3HgO53Z94
         2RAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="V/Q0c0q2";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n28sor495612qtn.18.2019.03.05.19.14.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Mar 2019 19:14:31 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="V/Q0c0q2";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:from:to:cc:references:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=3lMsB7qZB/O5v3pKAJRA9qupz0TGiaJREmmxihEt0HY=;
        b=V/Q0c0q2GaT3aUKveGUWepzUfUm6q3woELjOVYNaxAox68hFI+3A1CZAmueYHcOFMC
         K3/E5TztbwAU7hiZn2T0qbGXmjLF2dq0tp3yP43bO4epzgonE2CWBSD660LaI9TLnajL
         1AniDq/Sgv+TvQ2g6if2Ya8Z/ACq71o7vLk6ILore7wVLtlTPbrRePU45YkKTpfFokxw
         iMyvZCeBAQlO8TnW46kbwnSw8T8Qdi7c3qQEn0G4MBeAPs8Dv1gYrGJN580/GVVK0bbM
         yBK9ux9yDekVjZ8lVBJCtZroHIIoLNt3PlHCXlUPJWUiY78oM1V0rPJ0tcC9QXaBrZsC
         teYA==
X-Google-Smtp-Source: APXvYqyaHahewBUP4njm0JHWUxZayc7QffvHCiUMctd9WmE80ayPfULIXoGmZF1b1Pt8osy1TpX43A==
X-Received: by 2002:ac8:1c5d:: with SMTP id j29mr4026075qtk.113.1551842071180;
        Tue, 05 Mar 2019 19:14:31 -0800 (PST)
Received: from ovpn-120-151.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id l24sm280100qtf.27.2019.03.05.19.14.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 19:14:30 -0800 (PST)
Subject: Re: low-memory crash with patch "capture a page under direct
 compaction"
From: Qian Cai <cai@lca.pw>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: vbabka@suse.cz, Linux-MM <linux-mm@kvack.org>
References: <604a92ae-cbbb-7c34-f9aa-f7c08925bedf@lca.pw>
 <20190305144234.GH9565@techsingularity.net> <1551798804.7087.7.camel@lca.pw>
 <20190305152759.GI9565@techsingularity.net>
 <1d3a13fc-72b4-005a-7d73-2203b1ff25e4@lca.pw>
Message-ID: <5eecbceb-2522-c880-7d6a-af20cf548500@lca.pw>
Date: Tue, 5 Mar 2019 22:14:29 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <1d3a13fc-72b4-005a-7d73-2203b1ff25e4@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000011, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I don't understand this part.

@@ -2279,14 +2286,24 @@ static enum compact_result compact_zone_order(struct
zone *zone, int order,
                .ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY),
                .ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY)
        };
+       struct capture_control capc = {
+               .cc = &cc,
+               .page = NULL,
+       };
+
+       if (capture)
+               current->capture_control = &capc;


That check will always be true as it is,

struct page **capture;

*capture could be NULL, but not capture because in
__alloc_pages_direct_compact(), it does,

struct page *page = NULL;
capture = &page;

