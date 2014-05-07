Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 59D586B009A
	for <linux-mm@kvack.org>; Wed,  7 May 2014 18:05:25 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so1721007pab.14
        for <linux-mm@kvack.org>; Wed, 07 May 2014 15:05:25 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id to1si14469413pab.199.2014.05.07.15.05.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 15:05:24 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1736198pab.36
        for <linux-mm@kvack.org>; Wed, 07 May 2014 15:05:24 -0700 (PDT)
Date: Wed, 7 May 2014 15:05:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 03/10] slab: move up code to get kmem_cache_node in
 free_block()
In-Reply-To: <20140507215012.11213.qmail@ns.horizon.com>
Message-ID: <alpine.DEB.2.02.1405071502040.25024@chino.kir.corp.google.com>
References: <20140507215012.11213.qmail@ns.horizon.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 May 2014, George Spelvin wrote:

> > I think this unnecessarily obfuscates the code.
> 
> Thanks for the feedback!  (Even if it's negative, I appreciate it.)
> 
> To me, the confusing thing is the whole passing-a-pointer-to-a-pointer
> business.  How about the following, which makes set_obj_pfmemalloc and
> clear_obj_pfmemalloc take void *, not void **?  Is this better, or worse?
> 

A function called clear_obj_pfmemalloc() doesn't indicate it's returning 
anything, I think the vast majority of people would believe that it 
returns void just as it does.  There's no complier generated code 
optimization with this patch and I'm not sure it's even correct since 
you're now clearing after doing recheck_pfmemalloc_active().

I think it does make sense to remove the pointless "return;" in 
set_obj_pfmemalloc(), however.  Not sure it's worth asking someone to 
merge it, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
