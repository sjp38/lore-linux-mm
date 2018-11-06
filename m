Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 254D46B033A
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 10:31:32 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id n9-v6so12720342pfg.12
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 07:31:32 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id d12-v6si47339531pga.81.2018.11.06.07.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 07:31:30 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 06 Nov 2018 21:01:29 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v6 1/2] memory_hotplug: Free pages as higher order
In-Reply-To: <20181106140638.GN27423@dhcp22.suse.cz>
References: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
 <20181106140638.GN27423@dhcp22.suse.cz>
Message-ID: <542cd3516b54d88d1bffede02c6045b8@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On 2018-11-06 19:36, Michal Hocko wrote:
> On Tue 06-11-18 11:33:13, Arun KS wrote:
>> When free pages are done with higher order, time spend on
>> coalescing pages by buddy allocator can be reduced. With
>> section size of 256MB, hot add latency of a single section
>> shows improvement from 50-60 ms to less than 1 ms, hence
>> improving the hot add latency by 60%. Modify external
>> providers of online callback to align with the change.
>> 
>> This patch modifies totalram_pages, zone->managed_pages and
>> totalhigh_pages outside managed_page_count_lock. A follow up
>> series will be send to convert these variable to atomic to
>> avoid readers potentially seeing a store tear.
> 
> Is there any reason to rush this through rather than wait for counters
> conversion first?

Sure Michal.

Conversion patch, https://patchwork.kernel.org/cover/10657217/ is 
currently incremental to this patch. I ll change the order. Will wait 
for preparatory patch to settle first.

Regards,
Arun.

> 
> The patch as is looks good to me - modulo atomic counters of course. I
> cannot really judge whether existing updaters do really race in 
> practice
> to take this riskless.
> 
> The improvement is nice of course but this is a rare operation and 50ms
> vs 1ms is hardly noticeable. So I would rather wait for the preparatory
> work to settle. Btw. is there anything blocking that? It seems to be
> mostly automated.
