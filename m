Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD5F6B0035
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 19:36:48 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id 29so342217yhl.5
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:36:48 -0800 (PST)
Received: from mail-yh0-x230.google.com (mail-yh0-x230.google.com [2607:f8b0:4002:c01::230])
        by mx.google.com with ESMTPS id q66si2758743yhm.279.2014.01.14.16.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 16:36:47 -0800 (PST)
Received: by mail-yh0-f48.google.com with SMTP id f11so320370yha.7
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:36:47 -0800 (PST)
Date: Tue, 14 Jan 2014 16:36:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [slub] WARNING: CPU: 0 PID: 0 at mm/slub.c:1511
 __kmem_cache_create()
In-Reply-To: <52D5746F.2040604@intel.com>
Message-ID: <alpine.DEB.2.02.1401141634580.3375@chino.kir.corp.google.com>
References: <20140114131915.GA26942@localhost> <52D5746F.2040604@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Jan 2014, Dave Hansen wrote:

> > https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=c65c1877bd6826ce0d9713d76e30a7bed8e49f38
> 
> I think the assert is just bogus at least in the early case.
> early_kmem_cache_node_alloc() says:
>  * No kmalloc_node yet so do it by hand. We know that this is the first
>  * slab on the node for this slabcache. There are no concurrent accesses
>  * possible.
> 
> Should we do something like the attached patch?  (very lightly tested)
> 

Yeah, I think that's the best option to keep the runtime checking to 
ensure the proper lock is held on debug kernels with lockdep enabled and 
is better than reverting back to the comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
