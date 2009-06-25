Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C5D176B0062
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 03:12:04 -0400 (EDT)
Subject: Re: [this_cpu_xx V2 13/19] Use this_cpu operations in slub
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <alpine.DEB.1.10.0906180959070.15556@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
	 <20090617203445.302169275@gentwo.org>
	 <84144f020906172320k39ea5132h823449abc3124b30@mail.gmail.com>
	 <84144f020906172325m5de946gd8aa90328da26906@mail.gmail.com>
	 <alpine.DEB.1.10.0906180959070.15556@gentwo.org>
Date: Thu, 25 Jun 2009 10:12:19 +0300
Message-Id: <1245913939.2018.29.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net, heiko.carstens@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jun 2009, Pekka Enberg wrote:
> > Oh, and how does this work with the early boot slab code? We're
> > creating all the kmalloc caches with interrupts disabled and doing
> > per-cpu allocations, no?

On Thu, 2009-06-18 at 09:59 -0400, Christoph Lameter wrote:
> DMA slabs are not used during early bootup.

Actually, I think s390 is starting to use them during early boot:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=964cf35c88f93b4927dbc4e950dfa4d880c7f9d1

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
