Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92B9E2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 10:18:51 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z1so38459802wrz.10
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 07:18:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p91si6107862wrc.257.2017.06.30.07.18.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 07:18:50 -0700 (PDT)
Date: Fri, 30 Jun 2017 16:18:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: "mm: use early_pfn_to_nid in page_ext_init" broken on some
 configurations?
Message-ID: <20170630141847.GN22917@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

fe53ca54270a ("mm: use early_pfn_to_nid in page_ext_init") seem
to silently depend on CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID resp.
CONFIG_HAVE_MEMBLOCK_NODE_MAP. early_pfn_to_nid is returning zero with
!defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) && !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
I am not sure how widely is this used but such a code is tricky. I see
how catching early allocations during defered initialization might be
useful but a subtly broken code sounds like a problem to me.  So is
fe53ca54270a worth this or we should revert it?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
