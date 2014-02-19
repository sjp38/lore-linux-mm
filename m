Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id A48B86B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 04:20:02 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hi5so336124wib.2
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 01:20:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bs18si14726433wib.18.2014.02.19.01.20.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 01:20:01 -0800 (PST)
Date: Wed, 19 Feb 2014 10:19:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: ppc: RECLAIM_DISTANCE 10?
Message-ID: <20140219091959.GD14783@dhcp22.suse.cz>
References: <20140218090658.GA28130@dhcp22.suse.cz>
 <alpine.DEB.2.02.1402181424490.20772@chino.kir.corp.google.com>
 <20140219081644.GA14783@dhcp22.suse.cz>
 <alpine.DEB.2.02.1402190017480.7280@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402190017480.7280@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Anton Blanchard <anton@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 19-02-14 00:20:21, David Rientjes wrote:
> On Wed, 19 Feb 2014, Michal Hocko wrote:
> 
> > > I strongly suspect that the patch is correct since powerpc node distances 
> > > are different than the architectures you're talking about and get doubled 
> > > for every NUMA domain that the hardware supports.
> > 
> > Even if the units of the distance is different on PPC should every NUMA
> > machine have zone_reclaim enabled? That doesn't right to me.
> > 
> 
> In my experience on powerpc it's very correct, there's typically a 
> significant latency in remote access and we don't have the benefit of a 
> SLIT that actually defines the locality between proximity domains like we 
> do on other architectures. 

Interesting. So is the PPC NUMA basically about local vs. very distant?
Should REMOTE_DISTANCE reflect that as well? Or can we have 
distance < REMOTE_DISTANCE and it would still make sense to have
zone_reclaim enabled?

[...]

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
