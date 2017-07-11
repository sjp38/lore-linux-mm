Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7BEC6B053A
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 13:26:31 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 23so1657228wry.4
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 10:26:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k36si1995008eda.31.2017.07.11.10.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 11 Jul 2017 10:26:30 -0700 (PDT)
Date: Tue, 11 Jul 2017 13:26:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmemmap, memory_hotplug: fallback to base pages for vmmap
Message-ID: <20170711172623.GB961@cmpxchg.org>
References: <20170711134204.20545-1-mhocko@kernel.org>
 <20170711142558.GE11936@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711142558.GE11936@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cristopher Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Michael,

On Tue, Jul 11, 2017 at 04:25:58PM +0200, Michal Hocko wrote:
> Ohh, scratch that. The patch is bogus. I have completely missed that
> vmemmap_populate_hugepages already falls back to
> vmemmap_populate_basepages. I have to revisit the bug report I have
> received to see what happened apart from the allocation warning. Maybe
> we just want to silent that warning.

Yep, this should be fixed in 8e2cdbcb86b0 ("x86-64: fall back to
regular page vmemmap on allocation failure").

I figure it's good to keep some sort of warning there, though, as it
could have performance implications when we fall back to base pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
