Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 58B9F6B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 08:58:43 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id v19so6298384obq.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 05:58:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121212201529.GD16230@one.firstfloor.org>
References: <1355331819-8728-1-git-send-email-js1304@gmail.com>
	<0000013b90beeb93-87f65a09-0cc3-419f-be26-5271148cb947-000000@email.amazonses.com>
	<20121212201529.GD16230@one.firstfloor.org>
Date: Mon, 17 Dec 2012 22:58:42 +0900
Message-ID: <CAAmzW4P-MT9u_VzJ59t163TFPuDcyNX=tb5sC6WZ8sO20_Zjcg@mail.gmail.com>
Subject: Re: [PATCH] mm: introduce numa_zero_pfn
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

2012/12/13 Andi Kleen <andi@firstfloor.org>:
>> I would expect a processor to fetch the zero page cachelines from the l3
>> cache from other sockets avoiding memory transactions altogether. The zero
>> page is likely in use somewhere so no typically no memory accesses should
>> occur in a system.
>
> It depends on how effectively the workload uses the caches. If something
> is a cache pig of the L3 cache, then even shareable cache lines may need
> to be refetched regularly.
>
> But if your workloads spends a significant part of its time reading
> from zero page read only data there is something wrong with the workload.
>
> I would do some data profiling first to really prove that is the case.

Okay.
I didn't know about L3 cache, before.
Now, I think that I need some data profiling!
Thanks for comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
