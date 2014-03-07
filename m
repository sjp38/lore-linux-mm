Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id DC3FC6B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 15:54:48 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id md12so4679166pbc.9
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 12:54:48 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id vo7si9458346pab.219.2014.03.07.12.54.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Mar 2014 12:54:47 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id x10so4509427pdj.37
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 12:54:47 -0800 (PST)
Date: Fri, 7 Mar 2014 12:54:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mempool: add unlikely and likely hints
In-Reply-To: <alpine.LRH.2.02.1403070942090.12776@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.02.1403071254220.23969@chino.kir.corp.google.com>
References: <alpine.LRH.2.02.1403061713300.928@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.02.1403070210080.31668@chino.kir.corp.google.com> <alpine.LRH.2.02.1403070942090.12776@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org

On Fri, 7 Mar 2014, Mikulas Patocka wrote:

> > What observable performance benefit have you seen with this patch and 
> > with what architecture?  Could we include some data in the changelog?
> 
> None - you usually don't get observable performance benefit from 
> microoptimizations like this.
> 
> It may be that the cache line that the patch saves aliases some other 
> important cache lines and then, the patch saves two cache line refills. 
> Or, the saved cache line doesn't alias anything important and then the 
> patch doesn't have any effect at all. It's not worth spending many days or 
> weeks trying to recreate a situation when the code cache is used in such a 
> way that the patch would help.
> 

Not sure there's any benefit of merging the patch, then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
