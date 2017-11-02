Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 175C06B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:09:45 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o44so3014646wrf.0
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:09:45 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id a27si2185651edb.366.2017.11.02.06.09.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 06:09:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 86905987F1
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 13:09:43 +0000 (UTC)
Date: Thu, 2 Nov 2017 13:09:43 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/3] mm, compaction: split off flag for not updating skip
 hints
Message-ID: <20171102130943.7dpbuecrywtloein@techsingularity.net>
References: <20171102121706.21504-1-vbabka@suse.cz>
 <20171102121706.21504-2-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171102121706.21504-2-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Nov 02, 2017 at 01:17:05PM +0100, Vlastimil Babka wrote:
> Pageblock skip hints were added as a heuristic for compaction, which shares
> core code with CMA. Since CMA reliability would suffer from the heuristics,
> compact_control flag ignore_skip_hint was added for the CMA use case.
> Since commit 6815bf3f233e ("mm/compaction: respect ignore_skip_hint in
> update_pageblock_skip") the flag also means that CMA won't *update* the skip
> hints in addition to ignoring them.
> 
> Today, direct compaction can also ignore the skip hints in the last resort
> attempt, but there's no reason not to set them when isolation fails in such
> case. Thus, this patch splits off a new no_set_skip_hint flag to avoid the
> updating, which only CMA sets. This should improve the heuristics a bit, and
> allow us to simplify the persistent skip bit handling as the next step.
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
