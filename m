Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 37DDC440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 07:38:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b189so8804295wmb.12
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:38:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j200si2249177wmf.2.2017.07.14.04.38.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 04:38:43 -0700 (PDT)
Date: Fri, 14 Jul 2017 13:38:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/9] mm, page_alloc: rip out ZONELIST_ORDER_ZONE
Message-ID: <20170714113840.GI2618@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-2-mhocko@kernel.org>
 <20170714093650.l67vbem2g4typkta@suse.de>
 <20170714104756.GD2618@dhcp22.suse.cz>
 <20170714111633.gk5rpu2d5ghkbrrd@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170714111633.gk5rpu2d5ghkbrrd@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Fri 14-07-17 12:16:33, Mel Gorman wrote:
> On Fri, Jul 14, 2017 at 12:47:57PM +0200, Michal Hocko wrote:
> > > That should to be "default" because the original code would have the proc
> > > entry display "default" unless it was set at runtime. Pretty weird I
> > > know but it's always possible someone is parsing the original default
> > > and not handling it properly.
> > 
> > Ohh, right! That is indeed strange. Then I guess it would be probably
> > better to simply return Node to make it clear what the default is. What
> > do you think?
> > 
> 
> That would work too. The casing still matches.

This folded in?
---
