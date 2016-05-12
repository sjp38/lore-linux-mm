Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D04D26B0253
	for <linux-mm@kvack.org>; Thu, 12 May 2016 08:09:56 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so22729776lfq.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 05:09:56 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id wn2si15921474wjc.72.2016.05.12.05.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 05:09:55 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mm, compaction: avoid uninitialized variable use
Date: Thu, 12 May 2016 14:04:10 +0200
Message-ID: <4247828.QFzDnOkjoa@wuerfel>
In-Reply-To: <20160512061636.GA4200@dhcp22.suse.cz>
References: <1462973126-1183468-1-git-send-email-arnd@arndb.de> <20160512061636.GA4200@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thursday 12 May 2016 08:16:36 Michal Hocko wrote:
> I think this would be slightly better than your proposal. Andrew, could
> you fold it into the original
> mm-compaction-simplify-__alloc_pages_direct_compact-feedback-interface.patch
> patch?
> ---
> From 434bc8b6f3787724327499998c4fe651e8ce5d68 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 12 May 2016 08:10:33 +0200
> Subject: [PATCH] mmotm:
>  mm-compaction-simplify-__alloc_pages_direct_compact-feedback-interface-fix
> 
> Arnd has reported the following compilation warning:
> mm/page_alloc.c: In function '__alloc_pages_nodemask':
> mm/page_alloc.c:3651:6: error: 'compact_result' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This should be a false positive TRANSPARENT_HUGEPAGE depends on COMPACTION
> so is_thp_gfp_mask shouldn't be true. GFP_TRANSHUGE is a bit tricky
> and somebody might be using this accidently. Make sure that compact_result
> is defined also for !CONFIG_COMPACT and set it to COMPACT_SKIPPED because
> the compaction was really withdrawn.
> 
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>

Looks much nicer than my version.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
