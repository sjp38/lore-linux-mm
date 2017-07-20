Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F16656B0292
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 04:15:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 92so12076919wra.11
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:15:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6si1866135wrb.446.2017.07.20.01.15.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 01:15:09 -0700 (PDT)
Date: Thu, 20 Jul 2017 10:15:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/9] mm, memory_hotplug: drop zone from
 build_all_zonelists
Message-ID: <20170720081505.GE9058@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-5-mhocko@kernel.org>
 <d32539e9-8ac3-7536-a205-8953d436b301@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d32539e9-8ac3-7536-a205-8953d436b301@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Wen Congyang <wency@cn.fujitsu.com>

On Wed 19-07-17 15:33:32, Vlastimil Babka wrote:
> On 07/14/2017 10:00 AM, Michal Hocko wrote:
[...]
> > @@ -5146,19 +5145,14 @@ build_all_zonelists_init(void)
> >   * unless system_state == SYSTEM_BOOTING.
> >   *
> >   * __ref due to (1) call of __meminit annotated setup_zone_pageset
> 
> Isn't the whole (1) in the comment invalid now?

Yeah, I will drop it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
