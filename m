Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 79D296B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 22:51:14 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so1997185pbc.26
        for <linux-mm@kvack.org>; Wed, 21 May 2014 19:51:14 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id vx5si31593111pab.104.2014.05.21.19.51.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 19:51:13 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id bj1so1988742pad.41
        for <linux-mm@kvack.org>; Wed, 21 May 2014 19:51:13 -0700 (PDT)
Date: Wed, 21 May 2014 19:51:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/2] mm/compaction: avoid rescanning pageblocks in
 isolate_freepages
In-Reply-To: <5379D99E.1020302@suse.cz>
Message-ID: <alpine.DEB.2.02.1405211950430.13243@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com> <1399464550-26447-1-git-send-email-vbabka@suse.cz> <1399464550-26447-2-git-send-email-vbabka@suse.cz> <5379D99E.1020302@suse.cz>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1088296400-1400727068=:13243"
Content-ID: <alpine.DEB.2.02.1405211951100.13243@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1088296400-1400727068=:13243
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.02.1405211951101.13243@chino.kir.corp.google.com>

On Mon, 19 May 2014, Vlastimil Babka wrote:

> Fix a (spurious) build warning:
> 
> mm/compaction.c:860:15: warning: a??next_free_pfna?? may be used uninitialized in this function [-Wmaybe-uninitialized]
> 
> Seems like the compiler cannot prove that exiting the for loop without updating
> next_free_pfn there will mean that the check for crossing the scanners will
> trigger. So let's not confuse people who try to see why this warning occurs.
> 
> Instead of initializing next_free_pfn to zero with an explaining comment, just
> drop the damned variable altogether and work with cc->free_pfn directly as
> Nayoa originally suggested.
> 

s/Nayoa/Naoya/

> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>
--531381512-1088296400-1400727068=:13243--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
