Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 491986B007E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:56:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r5so29632974wmr.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:56:34 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id d67si17614994wma.100.2016.06.16.08.56.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 08:56:33 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id E69BC992BB
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 15:56:32 +0000 (UTC)
Date: Thu, 16 Jun 2016 16:56:31 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 14/27] mm, workingset: Make working set detection
 node-aware
Message-ID: <20160616155631.GK1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-15-git-send-email-mgorman@techsingularity.net>
 <71c0c1c1-0a5c-2d76-d16b-e4d29a18a6b8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <71c0c1c1-0a5c-2d76-d16b-e4d29a18a6b8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 16, 2016 at 05:13:51PM +0200, Vlastimil Babka wrote:
> On 06/09/2016 08:04 PM, Mel Gorman wrote:
> >Working set and refault detection is still zone-based, fix it.
> >
> >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> >Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> If you wanted, workingset_eviction() could obtain pgdat without going
> through zone.

Yeah, saves a few lookups. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
