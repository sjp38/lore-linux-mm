Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 662416B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:58:09 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so13431965lfi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:58:09 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s7si2572337wme.118.2016.07.12.07.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 07:58:08 -0700 (PDT)
Date: Tue, 12 Jul 2016 10:58:01 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 18/34] mm: rename NR_ANON_PAGES to NR_ANON_MAPPED
Message-ID: <20160712145801.GJ5881@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-19-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-19-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:54AM +0100, Mel Gorman wrote:
> NR_FILE_PAGES  is the number of        file pages.
> NR_FILE_MAPPED is the number of mapped file pages.
> NR_ANON_PAGES  is the number of mapped anon pages.
> 
> This is unhelpful naming as it's easy to confuse NR_FILE_MAPPED and
> NR_ANON_PAGES for mapped pages.  This patch renames NR_ANON_PAGES so we
> have
> 
> NR_FILE_PAGES  is the number of        file pages.
> NR_FILE_MAPPED is the number of mapped file pages.
> NR_ANON_MAPPED is the number of mapped anon pages.

That looks wrong to me. The symmetry is between NR_FILE_PAGES and
NR_ANON_PAGES. NR_FILE_MAPPED is merely elaborating on the mapped
subset of NR_FILE_PAGES, something which isn't necessary for anon
pages as they're always mapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
