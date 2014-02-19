Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 298A66B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 16:45:17 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so957051pab.18
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 13:45:16 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id nd12si1114447pab.330.2014.02.19.13.45.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 13:45:16 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so964933pbb.20
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 13:45:15 -0800 (PST)
Date: Wed, 19 Feb 2014 13:45:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: ppc: RECLAIM_DISTANCE 10?
In-Reply-To: <20140219091959.GD14783@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1402191339000.31921@chino.kir.corp.google.com>
References: <20140218090658.GA28130@dhcp22.suse.cz> <alpine.DEB.2.02.1402181424490.20772@chino.kir.corp.google.com> <20140219081644.GA14783@dhcp22.suse.cz> <alpine.DEB.2.02.1402190017480.7280@chino.kir.corp.google.com>
 <20140219091959.GD14783@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Anton Blanchard <anton@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 19 Feb 2014, Michal Hocko wrote:

> Interesting. So is the PPC NUMA basically about local vs. very distant?

The point is that it's impossible to tell how distant they are from one 
NUMA domain to the next NUMA domain.

> Should REMOTE_DISTANCE reflect that as well? Or can we have 
> distance < REMOTE_DISTANCE and it would still make sense to have
> zone_reclaim enabled?
> 

Ppc doesn't want to allocate in a different NUMA domain unless required, 
the latency of a remote access is too high.  Everything that isn't in the 
same domain has a distance >10 and is setup as 2^(domain hops) * 10.  We 
don't have the ability like with a SLIT to define remote nodes to have 
local latency vs remote or costly latency so the safe setting is a 
RECLAIM_DISTANCE of 10.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
