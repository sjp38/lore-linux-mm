Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 09CDA6B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 06:20:48 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id p9so697235lbv.38
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 03:20:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yx8si2245902lbb.69.2014.09.05.03.20.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 03:20:47 -0700 (PDT)
Date: Fri, 5 Sep 2014 11:20:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm: clean up zone flags
Message-ID: <20140905102044.GG17501@suse.de>
References: <1409668074-16875-1-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1409021437160.28054@chino.kir.corp.google.com>
 <20140902222653.GA20186@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140902222653.GA20186@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 02, 2014 at 06:26:53PM -0400, Johannes Weiner wrote:
> From 2420ad16df0634e073ad327f0f72472d9b03762b Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Tue, 2 Sep 2014 10:14:36 -0400
> Subject: [patch] mm: clean up zone flags
> 
> Page reclaim tests zone_is_reclaim_dirty(), but the site that actually
> sets this state does zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY), sending
> the reader through layers indirection just to track down a simple bit.
> 
> Remove all zone flag wrappers and just use bitops against zone->flags
> directly.  It's just as readable and the lines are barely any longer.
> 
> Also rename ZONE_TAIL_LRU_DIRTY to ZONE_DIRTY to match ZONE_WRITEBACK,
> and remove the zone_flags_t typedef.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: David Rientjes <rientjes@google.com>

I would have gone with making them ZONE_TAIL_DIRTY and ZONE_TAIL_WRITEBACK
because to me it's clearer what the flag means.  ZONE_DIRTY can be
interpreted as "the zone has dirty pages" which is not what reclaim
cares about, it cares about dirty pages at the tail of the LRU.  However,
I don't feel strongly enough to make a big deal about it so

Acked-by: Mel Gorman <mgorman@suse.de>

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
