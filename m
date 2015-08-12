Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA836B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 08:27:38 -0400 (EDT)
Received: by wijp15 with SMTP id p15so215513236wij.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:27:38 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id dq1si11253295wid.88.2015.08.12.05.27.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 05:27:37 -0700 (PDT)
Received: by wijp15 with SMTP id p15so215512344wij.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:27:36 -0700 (PDT)
Date: Wed, 12 Aug 2015 14:27:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: use after free and panic in free_pages_and_swap_cache
Message-ID: <20150812122734.GB5182@dhcp22.suse.cz>
References: <55C8A902.4080207@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55C8A902.4080207@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 10-08-15 09:37:06, Sasha Levin wrote:
> Hi all,

Hi Sasha,

> While fuzzing with trinity inside a KVM tools guest running -next I've
> stumbled on the following:

Could post your config somewhere please? Or maybe just the disassemble
of free_pages_and_swap_cache and tlb_flush_mmu_free should be sufficient.

I am not sure I read the report properly. It all seem to point to
free_pages_and_swap_cache resp. tlb_flush_mmu_free but I fail to see
what could be wrong there.  The last reference on the page should be
dropped in release_pages.  The given pages array shouldn't be freed
behind our back as well because mmu_gather is local to this path.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
