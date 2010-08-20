Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB186004CE
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 17:07:03 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o7KL6xxj028222
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:06:59 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz17.hot.corp.google.com with ESMTP id o7KL6uvk012966
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:06:58 -0700
Received: by pvg7 with SMTP id 7so1623468pvg.17
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:06:56 -0700 (PDT)
Date: Fri, 20 Aug 2010 14:06:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup4 0/6] SLUB: Cleanups V4
In-Reply-To: <20100820173711.136529149@linux.com>
Message-ID: <alpine.DEB.2.00.1008201405080.4202@chino.kir.corp.google.com>
References: <20100820173711.136529149@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010, Christoph Lameter wrote:

> Patch 3
> 
> Remove static allocation of kmem_cache_cpu array and rely on the
> percpu allocator to allocate memory for the array on bootup.
> 

I don't see this patch in the v4 posting of your series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
