Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1C43C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:44:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9916206B6
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:44:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9916206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 408988E0002; Fri, 15 Feb 2019 12:44:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B38D8E0001; Fri, 15 Feb 2019 12:44:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A29B8E0002; Fri, 15 Feb 2019 12:44:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5F5E8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:44:21 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d9so4270129edl.16
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:44:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hpZV921R2s5BiQ0fkqDCZf+S0eeUWJcfw+lSEjrZUDU=;
        b=ZQd4TCb9jetXstJ600CR/xZgrucsGfC6wewHhyDy6UQNl1PhThGTBMnx6zmNt+hPCM
         ngEf4RLooffRpLFRTOZKXcGWip8L/OeQpxwW0/7TqAGNcxqZ1mh2t8sqVLPUuC5FGn24
         ATblw4CHKz/N0R1AxKWn+y+j0UMNicIfkLThNURvfhSbmIrCwGxVLNkbnpkzOvU9a22e
         tu1Wl7/7AxY9w2t8VtiTZ7dWgEWigP70wn0Y4JvGL8tb41jHrUp2KFiEoqh81o4Do3D6
         qMH43qDgFVXj9H4dWGuBVa6d27FkptWf45EzlcyomGp3h0NqK7Cf38WTy8foc3yRTNz/
         AT4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAubTWwWXBB/sIpbUtJTl41zgyxzEJmf7Te1G8Hv4POxxmYdiE+VQ
	lTXMumVxFEYH5oTQJ8A8jrP5MR9y35QbmybcqlZTAaQmAae0cSpf4aDYtG8LyZh2mUXTggPzr0y
	1W3tpc7Ya/DRQwtNqj1cAkzRgDd+BfjcuEbREPkR3KHuQ88GtEaWjCBMayQmlihd83g==
X-Received: by 2002:a50:ac3d:: with SMTP id v58mr8358709edc.263.1550252661341;
        Fri, 15 Feb 2019 09:44:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbaBEAyFYlQXZD00Pu9SgfpYNHWHVBRQIzWqS5jipdVbYUgN/btp7eH5iMdWNsehbBc8S5R
X-Received: by 2002:a50:ac3d:: with SMTP id v58mr8358659edc.263.1550252660355;
        Fri, 15 Feb 2019 09:44:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550252660; cv=none;
        d=google.com; s=arc-20160816;
        b=JlHYUbx4P48vqtqXDiIdRiYtoUHFxY0v4FYaQKRRVVh0SBZDSucOS/6GatCRoMEF5F
         WsAIA5f990hu1Iq76PZjQQGbHWNU3tJePlXsnSdnzQb//kF4VMOoFFbX4erpAaLwXIi2
         LZveCpsxxlVpvMWu2JRh0h5StvcbDxXKfG2D9SxQmUBK3KxRZpk0MJo3amXuaKUM5lrN
         pgHUSsMLFW9m3MkIejCKkOTfWUIlmdiA4E39VpSqjnTxNfR8SVK8kdmAeHWDhtjzR/Kg
         KaYFv6Wj04ybV7t65/ZjhgbBeHARktTNJVI4X849oxwhBOITrgiiR1d1mWu9zKHBEaGQ
         12og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=hpZV921R2s5BiQ0fkqDCZf+S0eeUWJcfw+lSEjrZUDU=;
        b=0WTO6c7341RVX3B947beuIXNbydWl12upF3hWuY6iPPCL2zxjb//Q8iUu+2KAiVccf
         SgUNRPFsrIxgJatbn5WeEEk5nmnPtqJCT0ijWGTcK0JHdkHkmJh0cKeck8s2eWhFMMZ1
         vkGFIe9DPhtCsXDzzcjSuRlJ88Ga8ThVWPx8wW+YCn1zzGKPmX0CJuSJjV8jm/YTj/of
         QJHpkcqtvuhxeGIsMe3hM5Owva0T5yKauEPChRIdTJZTe3kBhcusnFSmL6eJc/diYCK/
         SOKDB6uOp843H/y+1uootNAg8qkq8jGZree2Sw8t/y43+XTSJF8zGeIyWt438mtKqJVS
         6Q1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10-v6si651996ejn.205.2019.02.15.09.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 09:44:20 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BFD95AD9F;
	Fri, 15 Feb 2019 17:44:19 +0000 (UTC)
Subject: Re: [linux-next-20190214] Free pages statistics is broken.
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
References: <201902150227.x1F2RBhh041762@www262.sakura.ne.jp>
 <20190215130147.GZ4525@dhcp22.suse.cz>
 <1189d67e-3672-5364-af89-501cad94a6ac@i-love.sakura.ne.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e7197148-4612-3d6a-f367-1c647193c509@suse.cz>
Date: Fri, 15 Feb 2019 18:44:18 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <1189d67e-3672-5364-af89-501cad94a6ac@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/15/19 3:27 PM, Tetsuo Handa wrote:
> On 2019/02/15 22:01, Michal Hocko wrote:
>> On Fri 15-02-19 11:27:10, Tetsuo Handa wrote:
>>> I noticed that amount of free memory reported by DMA: / DMA32: / Normal: fields are
>>> increasing over time. Since 5.0-rc6 is working correctly, some change in linux-next
>>> is causing this problem.
>> 
>> Just a shot into the dark. Could you try to disable the page allocator
>> randomization (page_alloc.shuffle kernel command line parameter)? Not
>> that I see any bug there but it is a recent change in the page allocator
>> I am aware of and it might have some anticipated side effects.
>> 
> 
> I tried CONFIG_SHUFFLE_PAGE_ALLOCATOR=n but problem still exists.

I think it's the preparation patch [1], even with randomization off:

@@ -1910,7 +1900,7 @@ static inline void expand(struct zone *zone, struct page *page,
                if (set_page_guard(zone, &page[size], high, migratetype))
                        continue;
 
-               list_add(&page[size].lru, &area->free_list[migratetype]);
+               add_to_free_area(&page[size], area, migratetype);
                area->nr_free++;
                set_page_order(&page[size], high);
        }

This should have removed the 'area->nr_free++;' line, as add_to_free_area()
includes the increment.

[1] https://www.ozlabs.org/~akpm/mmotm/broken-out/mm-move-buddy-list-manipulations-into-helpers.patch

