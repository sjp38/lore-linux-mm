Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7233D6B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 11:41:59 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id y10so5317827wgg.25
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 08:41:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id j5si5750531wjq.0.2014.03.07.08.41.56
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 08:41:57 -0800 (PST)
Date: Fri, 7 Mar 2014 09:50:20 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] mempool: add unlikely and likely hints
In-Reply-To: <alpine.DEB.2.02.1403070210080.31668@chino.kir.corp.google.com>
Message-ID: <alpine.LRH.2.02.1403070942090.12776@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1403061713300.928@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.02.1403070210080.31668@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org



On Fri, 7 Mar 2014, David Rientjes wrote:

> On Thu, 6 Mar 2014, Mikulas Patocka wrote:
> 
> > This patch adds unlikely and likely hints to the function mempool_free. It
> > lays out the code in such a way that the common path is executed
> > straighforward and saves a cache line.
> > 
> 
> What observable performance benefit have you seen with this patch and 
> with what architecture?  Could we include some data in the changelog?

None - you usually don't get observable performance benefit from 
microoptimizations like this.

It may be that the cache line that the patch saves aliases some other 
important cache lines and then, the patch saves two cache line refills. 
Or, the saved cache line doesn't alias anything important and then the 
patch doesn't have any effect at all. It's not worth spending many days or 
weeks trying to recreate a situation when the code cache is used in such a 
way that the patch would help.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
