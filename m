Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id CC4FC6B0256
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 04:38:30 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so90386399wic.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 01:38:30 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id w11si28170006wie.106.2015.10.14.01.38.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 01:38:28 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so120064567wic.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 01:38:28 -0700 (PDT)
Date: Wed, 14 Oct 2015 10:38:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] gfp: GFP_RECLAIM_MASK should include __GFP_NO_KSWAPD
Message-ID: <20151014083827.GG28333@dhcp22.suse.cz>
References: <561DE9F3.504@intel.com>
 <20151014073428.GC28333@dhcp22.suse.cz>
 <561E0F9B.6090305@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <561E0F9B.6090305@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pan Xinhui <xinhuix.pan@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, nasa4836@gmail.com, mgorman@suse.de, alexander.h.duyck@redhat.com, aneesh.kumar@linux.vnet.ibm.com, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>

On Wed 14-10-15 16:17:31, Pan Xinhui wrote:
[...]
> I have a look at Mel's patchset. yes, it can help fix my kswapd issue.
> :) So I just need change my kmalloc's gfp_flag to GFP_ATOMIC &~
> __GFP_KSWAPD_RECLAIM, then slub will not wakeup kswpad.

As pointed out in my other email __GFP_ATOMIC would be more appropriate
because you shouldn't abuse memory reserves which are implicitly used
for GFP_ATOMIC requests.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
