Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 819086B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 01:03:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b25-v6so12076525pfn.10
        for <linux-mm@kvack.org>; Wed, 30 May 2018 22:03:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i67-v6sor3929995pfk.43.2018.05.30.22.03.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 22:03:08 -0700 (PDT)
Date: Thu, 31 May 2018 14:03:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix the NULL mapping case in __isolate_lru_page()
Message-ID: <20180531050302.GA24220@rodete-desktop-imager.corp.google.com>
References: <alpine.LSU.2.11.1805302014001.12558@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1805302014001.12558@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Huang, Ying" <ying.huang@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 08:23:16PM -0700, Hugh Dickins wrote:
> George Boole would have noticed a slight error in 4.16 commit 69d763fc6d3a
> ("mm: pin address_space before dereferencing it while isolating an LRU page").
> Fix it, to match both the comment above it, and the original behaviour.
> 
> Although anonymous pages are not marked PageDirty at first, we have an
> old habit of calling SetPageDirty when a page is removed from swap cache:
> so there's a category of ex-swap pages that are easily migratable, but
> were inadvertently excluded from compaction's async migration in 4.16.
> 
> Fixes: 69d763fc6d3a ("mm: pin address_space before dereferencing it while isolating an LRU page")
> Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks, Hugh.
