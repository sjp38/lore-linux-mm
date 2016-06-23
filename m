Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7AF828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:35:04 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id i12so139846795ywa.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 01:35:04 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id i13si3386621wmg.0.2016.06.23.01.35.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 01:35:03 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 8CBEB98A90
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 08:35:02 +0000 (UTC)
Date: Thu, 23 Jun 2016 09:35:01 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 16/27] mm: Move page mapped accounting to the node
Message-ID: <20160623083500.GO1868@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-17-git-send-email-mgorman@techsingularity.net>
 <20160621153206.2d72954b22dddee7f1d8b9a5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160621153206.2d72954b22dddee7f1d8b9a5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 21, 2016 at 03:32:06PM -0700, Andrew Morton wrote:
> On Tue, 21 Jun 2016 15:15:55 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > Reclaim makes decisions based on the number of pages that are mapped
> > but it's mixing node and zone information. Account NR_FILE_MAPPED and
> > NR_ANON_PAGES pages on the node.
> 
> <wading through rejects>
> 
> Boy, the difference between
> 
> 	__mod_zone_page_state(page_zone(page), ...
> 
> and
> 
> 	__mod_node_page_state(page_pgdat(page), ...
> 
> is looking subtle.  When and why to use one versus the other.  I'm not
> seeing any explanation of this in there but haven't yet looked hard.
> 

I'm not sure I see the problem. One applies for zone stats and the other
is for node. Granted, care is needed to use the correct one or a random
stat is updated instead of the one intended.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
