Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 489EA6B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 04:07:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 92so335316wra.11
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 01:07:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s27si11732933wra.57.2017.07.17.01.07.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 01:07:25 -0700 (PDT)
Date: Mon, 17 Jul 2017 09:07:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/9] mm, page_alloc: simplify zonelist initialization
Message-ID: <20170717080723.wctyyukherj7bkqt@suse.de>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-7-mhocko@kernel.org>
 <20170714124645.i3duhuie6cczlybr@suse.de>
 <20170714130242.GQ2618@dhcp22.suse.cz>
 <20170714141823.2j7t37t6zdzdf3sv@suse.de>
 <20170717060639.GA7397@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170717060639.GA7397@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 17, 2017 at 08:06:40AM +0200, Michal Hocko wrote:
> On Fri 14-07-17 15:18:23, Mel Gorman wrote:
> > Fairly sure that's not what you meant.
> > 
> > 
> > >  		pg_data_t *node = NODE_DATA(node_order[i]);
> > >  
> > > -		zoneref_idx = build_zonelists_node(node, zonelist, zoneref_idx);
> > > +		nr_zones = build_zonelists_node(node, zonelist, nr_zones);
> > 
> > I meant converting build_zonelists_node and passing in &nr_zones and
> > returning false when an empty node is encountered. In this context,
> > it's also not about zones, it really is nr_zonerefs. Rename nr_zones in
> > build_zonelists_node as well.
> 
> hmm, why don't we rather make it zonerefs based then. Something
> like the following?

Works for me.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
