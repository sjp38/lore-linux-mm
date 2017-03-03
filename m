Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0576B038A
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 17:46:06 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 10so58455327pgb.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 14:46:06 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s6sor7566643pgc.40.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Mar 2017 14:46:04 -0800 (PST)
Date: Fri, 3 Mar 2017 14:46:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, zoneinfo: print non-populated zones
In-Reply-To: <4acf16c5-c64b-b4f8-9a41-1926eed23fe1@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1703031445340.92298@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1703021525500.5229@chino.kir.corp.google.com> <4acf16c5-c64b-b4f8-9a41-1926eed23fe1@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 3 Mar 2017, Anshuman Khandual wrote:

> > This patch shows statistics for non-populated zones in /proc/zoneinfo.
> > The zones exist and hold a spot in the vm.lowmem_reserve_ratio array.
> > Without this patch, it is not possible to determine which index in the
> > array controls which zone if one or more zones on the system are not
> > populated.
> 
> Right, its a problem when it does not even display array elements with
> an index value associated with it. But changing the array display will
> break the interface where as displaying non populated zones in the
> /proc/zoneinfo does not break anything.
> 

Precisely.

> The name of the Boolean "populated" is bit misleading IMHO. What I think you
> want here is to invoke the callback if the zone is populated as well as this
> variable is true. The variable can be named something like 'assert_populated'.
> 

I like it, I'll send a v2.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
