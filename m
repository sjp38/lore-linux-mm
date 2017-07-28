Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB32A6B0513
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 05:38:03 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l3so38015315wrc.12
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:38:03 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id 192si4660615wmy.108.2017.07.28.02.38.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 02:38:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 49E6DF4033
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:38:02 +0000 (UTC)
Date: Fri, 28 Jul 2017 10:38:01 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/6] mm, kswapd: refactor kswapd_try_to_sleep()
Message-ID: <20170728093801.n62m3fzmoenax2ly@techsingularity.net>
References: <20170727160701.9245-1-vbabka@suse.cz>
 <20170727160701.9245-2-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170727160701.9245-2-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Jul 27, 2017 at 06:06:56PM +0200, Vlastimil Babka wrote:
> The code of kswapd_try_to_sleep() is unnecessarily hard to follow. Also we
> needlessly call prepare_kswapd_sleep() twice, if the first one fails.
> Restructure the code so that each non-success case is accounted and returns
> immediately.
> 
> This patch should not introduce any functional change, except when the first
> prepare_kswapd_sleep() would have returned false, and then the second would be
> true (because somebody else has freed memory), kswapd would sleep before this
> patch and now it won't. This has likely been an accidental property of the
> implementation, and extremely rare to happen in practice anyway.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
