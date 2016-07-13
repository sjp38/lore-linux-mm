Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25B746B0260
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:10:43 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so32856696lfi.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:10:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f20si885570wjq.43.2016.07.13.06.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 06:10:42 -0700 (PDT)
Date: Wed, 13 Jul 2016 09:10:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] mm: vmstat: account per-zone stalls and pages
 skipped during reclaim -fix
Message-ID: <20160713131038.GD9905@cmpxchg.org>
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
 <1468404004-5085-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468404004-5085-3-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 13, 2016 at 11:00:02AM +0100, Mel Gorman wrote:
> As pointed out by Johannes -- the PG prefix seems to stand for page, and
> all stat names that contain it represent some per-page event. PGSTALL is
> not a page event. This patch renames it.
> 
> This is a fix for the mmotm patch
> mm-vmstat-account-per-zone-stalls-and-pages-skipped-during-reclaim.patch
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Thanks

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
