Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 51D8D6B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 05:32:03 -0400 (EDT)
Received: by mail-lf0-f49.google.com with SMTP id c62so160703027lfc.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 02:32:03 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id x3si27335461wjy.198.2016.04.04.02.32.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 02:32:01 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 426B79909F
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 09:32:01 +0000 (UTC)
Date: Mon, 4 Apr 2016 10:31:59 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 4/4] mm, compaction: direct freepage allocation for
 async direct compaction
Message-ID: <20160404093159.GB4773@techsingularity.net>
References: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
 <1459414236-9219-5-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1459414236-9219-5-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Mar 31, 2016 at 10:50:36AM +0200, Vlastimil Babka wrote:
> The goal of direct compaction is to quickly make a high-order page available
> for the pending allocation. The free page scanner can add significant latency
> when searching for migration targets, although to succeed the compaction, the
> only important limit on the target free pages is that they must not come from
> the same order-aligned block as the migrated pages.
> 

What prevents the free pages being allocated from behind the migration
scanner? Having compaction abort when the scanners meet misses
compaction opportunities but it avoids the problem of Compactor A using
pageblock X as a migration target and Compactor B using pageblock X as a
migration source.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
