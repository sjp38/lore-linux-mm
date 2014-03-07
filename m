Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 87BC46B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 16:15:16 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id i8so5459231qcq.9
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 13:15:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a1si1936598qcn.12.2014.03.07.13.15.15
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 13:15:16 -0800 (PST)
Date: Fri, 7 Mar 2014 16:15:13 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] mempool: add unlikely and likely hints
In-Reply-To: <alpine.DEB.2.02.1403071254220.23969@chino.kir.corp.google.com>
Message-ID: <alpine.LRH.2.02.1403071557060.894@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1403061713300.928@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.02.1403070210080.31668@chino.kir.corp.google.com> <alpine.LRH.2.02.1403070942090.12776@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.02.1403071254220.23969@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org



On Fri, 7 Mar 2014, David Rientjes wrote:

> On Fri, 7 Mar 2014, Mikulas Patocka wrote:
> 
> > > What observable performance benefit have you seen with this patch and 
> > > with what architecture?  Could we include some data in the changelog?
> > 
> > None - you usually don't get observable performance benefit from 
> > microoptimizations like this.
> > 
> > It may be that the cache line that the patch saves aliases some other 
> > important cache lines and then, the patch saves two cache line refills. 
> > Or, the saved cache line doesn't alias anything important and then the 
> > patch doesn't have any effect at all. It's not worth spending many days or 
> > weeks trying to recreate a situation when the code cache is used in such a 
> > way that the patch would help.
> 
> Not sure there's any benefit of merging the patch, then.

That's right, no one can be sure. The patch maybe helps and maybe has no 
effect (it can't hurt) - so there is no reason not to merge it.

If you measured the effect of microoptimizations like this, you spend 
excessive amount of time doing it and in the end you either improve 
performance a little bit or not. If you apply the patch blindly without 
measuring, you either improve performance a little bit or not. So - trying 
to prove that it helps doesn't have any positive effect at all.

If the patch could hurt performance, it would be reasonable to do some 
measurement to prove that it doesn't. But this one can't hurt.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
