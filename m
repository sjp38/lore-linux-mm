Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id AE8CB6B0037
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 18:53:40 -0500 (EST)
Received: by mail-qa0-f50.google.com with SMTP id i13so82043qae.9
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 15:53:40 -0800 (PST)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id s9si45728472qak.81.2013.12.05.15.53.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 15:53:39 -0800 (PST)
Received: by mail-yh0-f47.google.com with SMTP id 29so13299552yhl.34
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 15:53:39 -0800 (PST)
Date: Thu, 5 Dec 2013 15:53:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/8] mm, mempolicy: remove per-process flag
In-Reply-To: <00000142c426b81a-45e6815b-bde4-483c-975e-ce1eea42a753-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.02.1312051550390.7717@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032117490.29733@chino.kir.corp.google.com>
 <00000142be3633ba-2a459537-58fb-444b-a99f-33ff5e5b2aed-000000@email.amazonses.com> <alpine.DEB.2.02.1312041651080.13608@chino.kir.corp.google.com> <00000142c426b81a-45e6815b-bde4-483c-975e-ce1eea42a753-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu, 5 Dec 2013, Christoph Lameter wrote:

> Specjbb? What does Java have to do with this?
> Can you run the synthetic in kernel slab benchmark.
> 
> Like this one https://lkml.org/lkml/2009/10/13/459
> 

We actually carry that in our production kernel and have updated it to 
build on 3.11, I'll run it and netperf TCP_RR as well, thanks.

> However, SLAB is still the allocator in use for RHEL which puts some
> importance on still supporting SLAB.
> 

Google also uses it exclusively so I'm definitely not saying that since 
it's not default that we can ignore it.  I haven't seen any performance 
regression in removing it, but I'll post the numbers on the slab benchmark 
and netperf TCP_RR when I have them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
