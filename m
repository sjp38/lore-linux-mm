Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2AB78E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 05:57:57 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so2796329edd.16
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 02:57:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l24si1211965edr.135.2019.01.09.02.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 02:57:56 -0800 (PST)
Date: Wed, 9 Jan 2019 11:57:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as higher
 order
Message-ID: <20190109105754.GR31793@dhcp22.suse.cz>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
 <fb6465c99b3ada2c6af587a7eb00016d96d56f77.camel@linux.intel.com>
 <20190108181352.GI31793@dhcp22.suse.cz>
 <bfb543b6e343c21c3e263a110f234e08@codeaurora.org>
 <20190109073718.GM31793@dhcp22.suse.cz>
 <a053bd9b93e71baae042cdfc3432f945@codeaurora.org>
 <20190109084031.GN31793@dhcp22.suse.cz>
 <e005e71b125b9b8ddee668d1df9ad5ec@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e005e71b125b9b8ddee668d1df9ad5ec@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Wed 09-01-19 16:12:48, Arun KS wrote:
[...]
> It will be called once per online of a section and the arg value is always
> set to 0 while entering online_pages_range.

You rare right that this will be the case in the most simple scenario.
But the point is that the callback can be called several times from
walk_system_ram_range and then your current code wouldn't work properly.
-- 
Michal Hocko
SUSE Labs
