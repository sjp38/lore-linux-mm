Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0196B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 03:26:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k27-v6so16016184wre.23
        for <linux-mm@kvack.org>; Thu, 31 May 2018 00:26:30 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id b7-v6si10053140edl.365.2018.05.31.00.26.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 00:26:29 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 89ABF1C1C3A
	for <linux-mm@kvack.org>; Thu, 31 May 2018 08:26:28 +0100 (IST)
Date: Thu, 31 May 2018 08:26:27 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: fix the NULL mapping case in __isolate_lru_page()
Message-ID: <20180531072627.bdnclijtjkbpmxds@techsingularity.net>
References: <alpine.LSU.2.11.1805302014001.12558@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1805302014001.12558@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, "Huang, Ying" <ying.huang@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs
