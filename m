Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id CA6816B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 08:58:24 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id t60so1160926wes.34
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 05:58:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v16si4796290wie.33.2014.07.23.05.58.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 05:58:23 -0700 (PDT)
Date: Wed, 23 Jul 2014 13:58:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: Avoid full RCU lookup of memcg for statistics
 updates
Message-ID: <20140723125818.GT10819@suse.de>
References: <1406114656-16350-1-git-send-email-mgorman@suse.de>
 <1406114656-16350-2-git-send-email-mgorman@suse.de>
 <20140723114449.GE1725@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140723114449.GE1725@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Jul 23, 2014 at 07:44:49AM -0400, Johannes Weiner wrote:
> On Wed, Jul 23, 2014 at 12:24:15PM +0100, Mel Gorman wrote:
> > When updating memcg VM statistics like PGFAULT we take the rcu read
> > lock and lookup the memcg. For statistic updates this is overkill
> > when the process may not belong to a memcg. This patch adds a light
> > check to check if a memcg potentially exists. It's race-prone in that
> > some VM stats may be missed when a process first joins a memcg but
> > that is not serious enough to justify a constant performance penalty.
> 
> Tasks always belong to a memcg, the root group per default.  There
> isn't really any accounting that could be omitted.
> 

Crap, ok, I had not taken that into account. The lookup of that cannot
really be avoided. It's a pity because the stats on the root memcg are
not likely to be that interesting. Thanks for reviewing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
