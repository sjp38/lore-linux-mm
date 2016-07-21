Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94AE66B0273
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:08:27 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b65so7580737wmg.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:08:27 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id a64si2043064wmc.86.2016.07.21.01.08.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 01:08:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id D29B51C1E88
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 09:08:25 +0100 (IST)
Date: Thu, 21 Jul 2016 09:08:24 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 5/5] mm: consider per-zone inactive ratio to deactivate
Message-ID: <20160721080824.GE10438@techsingularity.net>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <1469028111-1622-6-git-send-email-mgorman@techsingularity.net>
 <20160721053017.GB31865@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160721053017.GB31865@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 02:30:17PM +0900, Minchan Kim wrote:
> > The problem is due to the active deactivation logic in inactive_list_is_low.
> > 
> > 	Node 0 active_anon:404412kB inactive_anon:409040kB
> > 
> > IOW, (inactive_anon of node * inactive_ratio > active_anon of node) due to
> > highmem anonymous stat so VM never deactivates normal zone's anonymous pages.
> > 
> > This patch is a modified version of Minchan's original solution but based
> > upon it. The problem with Minchan's patch is that it didn't take memcg
> > into account and any low zone with an imbalanced list could force a rotation.
> 
> Could you explan why we should consider memcg here?
> 

It already was and there is no good reason to ignore it if it's memcg
reclaim.

> > In this page, a zone-constrained global reclaim will rotate the list if
> 
>           patch,
> 

I'll fix it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
