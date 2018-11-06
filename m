Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4CC6B0392
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 15:08:27 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id g16-v6so6364988eds.20
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 12:08:27 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d30-v6si820295ejo.242.2018.11.06.12.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 12:08:25 -0800 (PST)
Date: Tue, 6 Nov 2018 21:08:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 1/2] memory_hotplug: Free pages as higher order
Message-ID: <20181106200823.GT27423@dhcp22.suse.cz>
References: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
 <20181106140638.GN27423@dhcp22.suse.cz>
 <542cd3516b54d88d1bffede02c6045b8@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <542cd3516b54d88d1bffede02c6045b8@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Tue 06-11-18 21:01:29, Arun KS wrote:
> On 2018-11-06 19:36, Michal Hocko wrote:
> > On Tue 06-11-18 11:33:13, Arun KS wrote:
> > > When free pages are done with higher order, time spend on
> > > coalescing pages by buddy allocator can be reduced. With
> > > section size of 256MB, hot add latency of a single section
> > > shows improvement from 50-60 ms to less than 1 ms, hence
> > > improving the hot add latency by 60%. Modify external
> > > providers of online callback to align with the change.
> > > 
> > > This patch modifies totalram_pages, zone->managed_pages and
> > > totalhigh_pages outside managed_page_count_lock. A follow up
> > > series will be send to convert these variable to atomic to
> > > avoid readers potentially seeing a store tear.
> > 
> > Is there any reason to rush this through rather than wait for counters
> > conversion first?
> 
> Sure Michal.
> 
> Conversion patch, https://patchwork.kernel.org/cover/10657217/ is currently
> incremental to this patch.

The ordering should be other way around. Because as things stand with
this patch first it is possible to introduce a subtle race prone
updates. As I've said I am skeptical the race would matter, really, but
there is no real reason to risk for that. Especially when you have the
other (first) half ready.

-- 
Michal Hocko
SUSE Labs
