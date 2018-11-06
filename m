Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D79D6B032E
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 09:06:41 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m45-v6so7743791edc.2
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 06:06:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e19si3289019edv.104.2018.11.06.06.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 06:06:39 -0800 (PST)
Date: Tue, 6 Nov 2018 15:06:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 1/2] memory_hotplug: Free pages as higher order
Message-ID: <20181106140638.GN27423@dhcp22.suse.cz>
References: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Tue 06-11-18 11:33:13, Arun KS wrote:
> When free pages are done with higher order, time spend on
> coalescing pages by buddy allocator can be reduced. With
> section size of 256MB, hot add latency of a single section
> shows improvement from 50-60 ms to less than 1 ms, hence
> improving the hot add latency by 60%. Modify external
> providers of online callback to align with the change.
> 
> This patch modifies totalram_pages, zone->managed_pages and
> totalhigh_pages outside managed_page_count_lock. A follow up
> series will be send to convert these variable to atomic to
> avoid readers potentially seeing a store tear.

Is there any reason to rush this through rather than wait for counters
conversion first?

The patch as is looks good to me - modulo atomic counters of course. I
cannot really judge whether existing updaters do really race in practice
to take this riskless.

The improvement is nice of course but this is a rare operation and 50ms
vs 1ms is hardly noticeable. So I would rather wait for the preparatory
work to settle. Btw. is there anything blocking that? It seems to be
mostly automated.

-- 
Michal Hocko
SUSE Labs
