Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A83C6B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 07:49:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so13014396wmw.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 04:49:49 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id e133si3299583wmd.103.2016.05.05.04.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 04:49:48 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id w143so2980242wmw.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 04:49:48 -0700 (PDT)
Date: Thu, 5 May 2016 13:49:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: slab: remove ZONE_DMA_FLAG
Message-ID: <20160505114946.GI4386@dhcp22.suse.cz>
References: <1462381297-11009-1-git-send-email-yang.shi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462381297-11009-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Wed 04-05-16 10:01:37, Yang Shi wrote:
> Now we have IS_ENABLED helper to check if a Kconfig option is enabled or not,
> so ZONE_DMA_FLAG sounds no longer useful.
> 
> And, the use of ZONE_DMA_FLAG in slab looks pointless according to the
> comment [1] from Johannes Weiner, so remove them and ORing passed in flags with
> the cache gfp flags has been done in kmem_getpages().
> 
> [1] https://lkml.org/lkml/2014/9/25/553

I haven't checked the patch but I have a formal suggestion.
lkml.org tends to break and forget, please use
http://lkml.kernel.org/r/$msg-id instead. In this case
http://lkml.kernel.org/r/20140925185047.GA21089@cmpxchg.org

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
