Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 298086B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 09:03:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d127so2409171wmf.15
        for <linux-mm@kvack.org>; Wed, 17 May 2017 06:03:00 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id g188si2375236wme.23.2017.05.17.06.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 06:02:55 -0700 (PDT)
Date: Wed, 17 May 2017 14:02:43 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm: clarify why we want kmalloc before falling backto
 vmallock
Message-ID: <20170517130243.GQ26693@nuc-i3427.alporthouse.com>
References: <20170517080932.21423-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170517080932.21423-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

subject s/vmallock/vmalloc/

On Wed, May 17, 2017 at 10:09:32AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> While converting drm_[cm]alloc* helpers to kvmalloc* variants Chris
> Wilson has wondered why we want to try kmalloc before vmalloc fallback
> even for larger allocations requests. Let's clarify that one larger
> physically contiguous block is less likely to fragment memory than many
> scattered pages which can prevent more large blocks from being created.
> 
> Suggested-by: Chris Wilson <chris@chris-wilson.co.uk>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

It helped me understand the decisions made by the code, so
Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
