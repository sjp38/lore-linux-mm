Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 529A76B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 03:16:48 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id k14so46504wgh.2
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 00:16:47 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si17144794wjf.5.2014.02.19.00.16.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 00:16:46 -0800 (PST)
Date: Wed, 19 Feb 2014 09:16:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: ppc: RECLAIM_DISTANCE 10?
Message-ID: <20140219081644.GA14783@dhcp22.suse.cz>
References: <20140218090658.GA28130@dhcp22.suse.cz>
 <alpine.DEB.2.02.1402181424490.20772@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402181424490.20772@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Anton Blanchard <anton@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 18-02-14 14:27:11, David Rientjes wrote:
> On Tue, 18 Feb 2014, Michal Hocko wrote:
> 
> > Hi,
> > I have just noticed that ppc has RECLAIM_DISTANCE reduced to 10 set by
> > 56608209d34b (powerpc/numa: Set a smaller value for RECLAIM_DISTANCE to
> > enable zone reclaim). The commit message suggests that the zone reclaim
> > is desirable for all NUMA configurations.
> > 
> > History has shown that the zone reclaim is more often harmful than
> > helpful and leads to performance problems. The default RECLAIM_DISTANCE
> > for generic case has been increased from 20 to 30 around 3.0
> > (32e45ff43eaf mm: increase RECLAIM_DISTANCE to 30).
> > 
> > I strongly suspect that the patch is incorrect and it should be
> > reverted. Before I will send a revert I would like to understand what
> > led to the patch in the first place. I do not see why would PPC use only
> > LOCAL_DISTANCE and REMOTE_DISTANCE distances and in fact machines I have
> > seen use different values.
> > 
> 
> I strongly suspect that the patch is correct since powerpc node distances 
> are different than the architectures you're talking about and get doubled 
> for every NUMA domain that the hardware supports.

Even if the units of the distance is different on PPC should every NUMA
machine have zone_reclaim enabled? That doesn't right to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
