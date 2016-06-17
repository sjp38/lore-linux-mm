Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78C136B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:04:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so8911667wmr.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:04:02 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id 137si6265805wms.63.2016.06.17.05.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 05:04:01 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id CE35A1C2A6F
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 13:04:00 +0100 (IST)
Date: Fri, 17 Jun 2016 13:03:59 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 21/27] mm, vmscan: Only wakeup kswapd once per node for
 the requested classzone
Message-ID: <20160617120301.GM1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-22-git-send-email-mgorman@techsingularity.net>
 <2ce07fcf-7b7d-a70b-ed7b-60867ad4458f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2ce07fcf-7b7d-a70b-ed7b-60867ad4458f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 17, 2016 at 12:46:05PM +0200, Vlastimil Babka wrote:
> On 06/09/2016 08:04 PM, Mel Gorman wrote:
> >kswapd is woken when zones are below the low watermark but the wakeup
> >decision is not taking the classzone into account.  Now that reclaim is
> >node-based, it is only required to wake kswapd once per node and only if
> >all zones are unbalanced for the requested classzone.
> >
> >Note that one node might be checked multiple times but there is no cheap
> >way of tracking what nodes have already been visited for zoneslists that
> >be ordered by either zone or node.
> 
> Wouldn't it be possible to optimize for node order as you did in direct
> reclaim? Do the zone_balanced checks when going through zonelist, and once
> node changes in iteration, wake up if no eligible zones visited so far were
> balanced.
> 

Yeah, it is. I'll chuck it in.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
