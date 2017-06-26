Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21D0A6B0397
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:42:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f49so28712020wrf.5
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:42:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t16si11983800wrb.3.2017.06.26.05.42.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 05:42:37 -0700 (PDT)
Date: Mon, 26 Jun 2017 14:42:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/6] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
Message-ID: <20170626124233.GN11534@dhcp22.suse.cz>
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-3-mhocko@kernel.org>
 <db63b720-b7aa-1bd0-dde8-d324dfaa9c9b@suse.cz>
 <20170626121411.GK11534@dhcp22.suse.cz>
 <82f5331e-8a3d-ed61-3d5d-3dfcbf557072@suse.cz>
 <20170626123847.GM11534@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170626123847.GM11534@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 26-06-17 14:38:47, Michal Hocko wrote:
> On Mon 26-06-17 14:17:30, Vlastimil Babka wrote:
> > On 06/26/2017 02:14 PM, Michal Hocko wrote:
> > > On Mon 26-06-17 13:45:19, Vlastimil Babka wrote:
> > >> On 06/23/2017 10:53 AM, Michal Hocko wrote:
> > > [...]
> > >>> - GFP_KERNEL - both background and direct reclaim are allowed and the
> > >>>   _default_ page allocator behavior is used. That means that !costly
> > >>>   allocation requests are basically nofail (unless the requesting task
> > >>>   is killed by the OOM killer)
> > >>
> > >> Should we explicitly point out that failure must be handled? After lots
> > >> of talking about "too small to fail", people might get the wrong impression.
> > > 
> > > OK. What about the following.
> > > "That means that !costly allocation requests are basically nofail but
> > > there is no guarantee of thaat behavior so failures have to be checked
> > 
> >                            that
> > 
> > > properly by callers (e.g. OOM killer victim is allowed to fail
> > > currently).
> > 
> > Looks good, thanks!
> 
> Andrew, could you fold the following in and replace the GFP_KERNEL part
> of the changelog with the updated text. Thanks!

Forgot to address other thing spotted by Vlastimil.
---
