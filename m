Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B60D36B0391
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:30:02 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n11so30613570wma.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:30:02 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v124si15217629wmd.119.2017.03.06.08.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 08:30:01 -0800 (PST)
Date: Mon, 6 Mar 2017 11:24:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/9] mm: fix 100% CPU kswapd busyloop on unreclaimable
 nodes
Message-ID: <20170306162410.GB2090@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-2-hannes@cmpxchg.org>
 <20170303012609.GA3394@bbox>
 <20170303075954.GA31499@dhcp22.suse.cz>
 <20170306013740.GA8779@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306013740.GA8779@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Mar 06, 2017 at 10:37:40AM +0900, Minchan Kim wrote:
> On Fri, Mar 03, 2017 at 08:59:54AM +0100, Michal Hocko wrote:
> > On Fri 03-03-17 10:26:09, Minchan Kim wrote:
> > > On Tue, Feb 28, 2017 at 04:39:59PM -0500, Johannes Weiner wrote:
> > > > @@ -3316,6 +3325,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
> > > >  			sc.priority--;
> > > >  	} while (sc.priority >= 1);
> > > >  
> > > > +	if (!sc.nr_reclaimed)
> > > > +		pgdat->kswapd_failures++;
> > > 
> > > sc.nr_reclaimed is reset to zero in above big loop's beginning so most of time,
> > > it pgdat->kswapd_failures is increased.

That wasn't intentional; I didn't see the sc.nr_reclaimed reset.

---
