Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 961F58E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:25:37 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 82so11456127pfs.20
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 02:25:37 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si10749452ple.281.2018.12.17.02.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 02:25:36 -0800 (PST)
Date: Mon, 17 Dec 2018 11:25:34 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: clear zone_movable_pfn if the node
 doesn't have ZONE_MOVABLE
Message-ID: <20181217102534.GF30879@dhcp22.suse.cz>
References: <20181216125624.3416-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181216125624.3416-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@techsingularity.net, osalvador@suse.de

On Sun 16-12-18 20:56:24, Wei Yang wrote:
> A non-zero zone_movable_pfn indicates this node has ZONE_MOVABLE, while
> current implementation doesn't comply with this rule when kernel
> parameter "kernelcore=" is used.
> 
> Current implementation doesn't harm the system, since the value in
> zone_movable_pfn is out of the range of current zone. While user would
> see this message during bootup, even that node doesn't has ZONE_MOVABLE.
> 
>     Movable zone start for each node
>       Node 0: 0x0000000080000000

I am sorry but the above description confuses me more than it helps.
Could you start over again and describe the user visible problem, then
follow up with the udnerlying bug and finally continue with a proposed
fix?
-- 
Michal Hocko
SUSE Labs
