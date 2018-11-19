Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47C276B1A39
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:20:34 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c53so6710339edc.9
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 02:20:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l15-v6si1554327ejc.183.2018.11.19.02.20.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 02:20:32 -0800 (PST)
Date: Mon, 19 Nov 2018 11:20:30 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
Message-ID: <20181119102030.GD22247@dhcp22.suse.cz>
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
 <1542622061.3002.6.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542622061.3002.6.camel@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador <osalvador@suse.de>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org

On Mon 19-11-18 11:07:41, osalvador wrote:
[...]
> One thing I was wondering is that if we also should re-adjust it when a
> zone gets emptied during offlining memory.
> I checked, and whenever we work wirh pgdat->nr_zones we seem to check
> if the zone is populated in order to work with it.
> But still, I wonder if we should re-adjust it.

I would rather not because we are not really deallocating zones and once
you want to shrink it you have to linearize all the loops depending on
it.

-- 
Michal Hocko
SUSE Labs
