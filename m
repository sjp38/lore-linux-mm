Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4B5E6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:07:06 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id c1so21285250lbw.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:07:06 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id jk1si11732115wjb.0.2016.06.17.05.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 05:07:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 06ACC1C2667
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 13:07:05 +0100 (IST)
Date: Fri, 17 Jun 2016 13:07:03 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 24/27] mm, page_alloc: Remove fair zone allocation policy
Message-ID: <20160617120703.GN1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-25-git-send-email-mgorman@techsingularity.net>
 <9f30977a-ff07-d783-4c21-e13bd2478aa3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <9f30977a-ff07-d783-4c21-e13bd2478aa3@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On Fri, Jun 17, 2016 at 01:27:09PM +0200, Vlastimil Babka wrote:
> On 06/09/2016 08:04 PM, Mel Gorman wrote:
> >The fair zone allocation policy interleaves allocation requests between
> >zones to avoid an age inversion problem whereby new pages are reclaimed
> >to balance a zone. Reclaim is now node-based so this should no longer be
> >an issue and the fair zone allocation policy is not free. This patch
> >removes it.
> 
> I wonder if fair zone allocation had the side effect of preventing e.g. a
> small Normal zone to be almost fully occupied by long-lived unreclaimable
> allocations early in the kernel lifetime. So that might be one thing to
> watch out for.

It's a marginal corner case and the zonelist scan is slightly inefficient
as the first zone is always skipped but the impact is light.

> But otherwise I would agree it should be no longer needed
> with node-based reclaim.
> 
> >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
