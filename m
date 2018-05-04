Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 221316B0266
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:08:50 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id f6-v6so9700425pgs.13
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:08:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g63-v6si8921138pgc.40.2018.05.04.09.08.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 09:08:49 -0700 (PDT)
Date: Fri, 4 May 2018 18:08:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory_hotplug: Fix leftover use of struct page
 during hotplug
Message-ID: <20180504160844.GB23560@dhcp22.suse.cz>
References: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: linux-mm <linux-mm@kvack.org>, linuxarm@huawei.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri 04-05-18 09:53:11, Jonathan Cameron wrote:
> The case of a new numa node got missed in avoiding using
> the node info from page_struct during hotplug.  In this
> path we have a call to register_mem_sect_under_node (which allows
> us to specify it is hotplug so don't change the node),
> via link_mem_sections which unfortunately does not.

I have hard time to parse the problem description. Could you be more
specific and describe the user visible effect along with steps to
trigger the issue?
-- 
Michal Hocko
SUSE Labs
