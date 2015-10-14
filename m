Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC2E6B0255
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 04:43:43 -0400 (EDT)
Received: by ioii196 with SMTP id i196so47784873ioi.3
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 01:43:43 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id g12si6235538iod.92.2015.10.14.01.43.42
        for <linux-mm@kvack.org>;
        Wed, 14 Oct 2015 01:43:43 -0700 (PDT)
Message-ID: <561E150C.9010402@intel.com>
Date: Wed, 14 Oct 2015 16:40:44 +0800
From: Pan Xinhui <xinhuix.pan@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] gfp: GFP_RECLAIM_MASK should include __GFP_NO_KSWAPD
References: <561DE9F3.504@intel.com> <20151014073428.GC28333@dhcp22.suse.cz> <561E0F9B.6090305@intel.com> <20151014083827.GG28333@dhcp22.suse.cz>
In-Reply-To: <20151014083827.GG28333@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, nasa4836@gmail.com, mgorman@suse.de, alexander.h.duyck@redhat.com, aneesh.kumar@linux.vnet.ibm.com, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>



On 2015a1'10ae??14ae?JPY 16:38, Michal Hocko wrote:
> On Wed 14-10-15 16:17:31, Pan Xinhui wrote:
> [...]
>> I have a look at Mel's patchset. yes, it can help fix my kswapd issue.
>> :) So I just need change my kmalloc's gfp_flag to GFP_ATOMIC &~
>> __GFP_KSWAPD_RECLAIM, then slub will not wakeup kswpad.
> 
> As pointed out in my other email __GFP_ATOMIC would be more appropriate
> because you shouldn't abuse memory reserves which are implicitly used
> for GFP_ATOMIC requests.
> 

oh, yes. maybe it's better to use (__GFP_HIGH | __GFP_ATOMIC) than (GFP_ATOMIC &~ __GFP_KSWAPD_RECLAIM)..
just set the gfp flags which I need in kmalloc.

thanks for the suggestion.

thanks
xinhui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
