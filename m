Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5862B8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 06:06:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so4991701pfi.21
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 03:06:38 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id m8si13351707plt.171.2019.01.09.03.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 03:06:37 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 09 Jan 2019 16:36:36 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as higher
 order
In-Reply-To: <20190109105754.GR31793@dhcp22.suse.cz>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
 <fb6465c99b3ada2c6af587a7eb00016d96d56f77.camel@linux.intel.com>
 <20190108181352.GI31793@dhcp22.suse.cz>
 <bfb543b6e343c21c3e263a110f234e08@codeaurora.org>
 <20190109073718.GM31793@dhcp22.suse.cz>
 <a053bd9b93e71baae042cdfc3432f945@codeaurora.org>
 <20190109084031.GN31793@dhcp22.suse.cz>
 <e005e71b125b9b8ddee668d1df9ad5ec@codeaurora.org>
 <20190109105754.GR31793@dhcp22.suse.cz>
Message-ID: <2efb06e91d9af48bf3d1d38bd50e0458@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On 2019-01-09 16:27, Michal Hocko wrote:
> On Wed 09-01-19 16:12:48, Arun KS wrote:
> [...]
>> It will be called once per online of a section and the arg value is 
>> always
>> set to 0 while entering online_pages_range.
> 
> You rare right that this will be the case in the most simple scenario.
> But the point is that the callback can be called several times from
> walk_system_ram_range and then your current code wouldn't work 
> properly.

Thanks. Will use +=

Regards,
Arun
