Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CF3DB6B0039
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 11:25:17 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fb1so1088467pad.17
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 08:25:17 -0700 (PDT)
Received: from psmtp.com ([74.125.245.171])
        by mx.google.com with SMTP id xb5si2239715pab.316.2013.10.30.08.25.15
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 08:25:16 -0700 (PDT)
Date: Wed, 30 Oct 2013 15:25:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] Fix page_group_by_mobility_disabled breakage
Message-ID: <20131030152511.GQ2400@suse.de>
References: <1382724575-8450-1-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1382724575-8450-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, Oct 25, 2013 at 02:09:35PM -0400, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Currently, set_pageblock_migratetype screw up MIGRATE_CMA and
> MIGRATE_ISOLATE if page_group_by_mobility_disabled is true. It
> rewrite the argument to MIGRATE_UNMOVABLE and we lost these attribute.
> 
> The problem was introduced commit 49255c619f (page allocator: move
> check for disabled anti-fragmentation out of fastpath). So, 4 years
> lived issue may mean that nobody uses page_group_by_mobility_disabled.
> 

Nobody uses page_group_by_mobility_disabled with CMA at least.
page_group_by_mobility_disabled only kicks in automatically for small
machines so it's possible the condition is very rarely encountered.

Anyway

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
