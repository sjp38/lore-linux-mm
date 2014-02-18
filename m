Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 51DA76B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:27:14 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so17344457pab.15
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:27:14 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id yn1si6878184pab.284.2014.02.18.14.27.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:27:13 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so17442539pab.9
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:27:13 -0800 (PST)
Date: Tue, 18 Feb 2014 14:27:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: ppc: RECLAIM_DISTANCE 10?
In-Reply-To: <20140218090658.GA28130@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1402181424490.20772@chino.kir.corp.google.com>
References: <20140218090658.GA28130@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Anton Blanchard <anton@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 18 Feb 2014, Michal Hocko wrote:

> Hi,
> I have just noticed that ppc has RECLAIM_DISTANCE reduced to 10 set by
> 56608209d34b (powerpc/numa: Set a smaller value for RECLAIM_DISTANCE to
> enable zone reclaim). The commit message suggests that the zone reclaim
> is desirable for all NUMA configurations.
> 
> History has shown that the zone reclaim is more often harmful than
> helpful and leads to performance problems. The default RECLAIM_DISTANCE
> for generic case has been increased from 20 to 30 around 3.0
> (32e45ff43eaf mm: increase RECLAIM_DISTANCE to 30).
> 
> I strongly suspect that the patch is incorrect and it should be
> reverted. Before I will send a revert I would like to understand what
> led to the patch in the first place. I do not see why would PPC use only
> LOCAL_DISTANCE and REMOTE_DISTANCE distances and in fact machines I have
> seen use different values.
> 

I strongly suspect that the patch is correct since powerpc node distances 
are different than the architectures you're talking about and get doubled 
for every NUMA domain that the hardware supports.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
