Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 73F596B0062
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:57:46 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 43F3782C323
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:15:56 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1NDvPjecs5d8 for <linux-mm@kvack.org>;
	Thu, 18 Jun 2009 10:15:56 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8A81F82C3BD
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:15:51 -0400 (EDT)
Date: Thu, 18 Jun 2009 09:59:30 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [this_cpu_xx V2 13/19] Use this_cpu operations in slub
In-Reply-To: <84144f020906172325m5de946gd8aa90328da26906@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0906180959070.15556@gentwo.org>
References: <20090617203337.399182817@gentwo.org>  <20090617203445.302169275@gentwo.org>  <84144f020906172320k39ea5132h823449abc3124b30@mail.gmail.com> <84144f020906172325m5de946gd8aa90328da26906@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jun 2009, Pekka Enberg wrote:

> Oh, and how does this work with the early boot slab code? We're
> creating all the kmalloc caches with interrupts disabled and doing
> per-cpu allocations, no?

DMA slabs are not used during early bootup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
