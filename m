Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 872FB6B0038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 22:34:10 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id w7so6316001qcr.0
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 19:34:10 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id r9si10050010qas.100.2015.01.08.19.34.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 19:34:09 -0800 (PST)
Date: Thu, 8 Jan 2015 21:34:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm/slub: optimize alloc/free fastpath by removing
 preemption on/off
In-Reply-To: <20150108074447.GA25453@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1501082133350.22140@gentwo.org>
References: <1420421765-3209-1-git-send-email-iamjoonsoo.kim@lge.com> <1420513392.24290.2.camel@stgolabs.net> <20150106080948.GA18346@js1304-P5Q-DELUXE> <1420563737.24290.7.camel@stgolabs.net> <20150108074447.GA25453@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>

On Thu, 8 Jan 2015, Joonsoo Kim wrote:

> > You'd need a smp_wmb() in between tid and c in the loop then, which
> > looks quite unpleasant. All in all disabling preemption isn't really
> > that expensive, and you should redo your performance number if you go
> > this way.
>
> This barrier() is not for read/write synchronization between cpus.
> All read/write operation to cpu_slab would happen on correct cpu in
> successful case. What I'd need to guarantee here is to prevent
> reordering between fetching operation for correctness of algorithm. In
> this case, barrier() seems enough to me. Am I wrong?

You are right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
