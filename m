Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1E16B01B4
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 19:32:05 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o5QNW0G1013457
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:32:00 -0700
Received: from pvg16 (pvg16.prod.google.com [10.241.210.144])
	by wpaz33.hot.corp.google.com with ESMTP id o5QNVxF4001904
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:31:59 -0700
Received: by pvg16 with SMTP id 16so2498907pvg.23
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:31:59 -0700 (PDT)
Date: Sat, 26 Jun 2010 16:31:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q 06/16] slub: Use kmem_cache flags to detect if slab is in
 debugging mode.
In-Reply-To: <20100625212104.644784077@quilx.com>
Message-ID: <alpine.DEB.2.00.1006261631450.27174@chino.kir.corp.google.com>
References: <20100625212026.810557229@quilx.com> <20100625212104.644784077@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010, Christoph Lameter wrote:

> The cacheline with the flags is reachable from the hot paths after the
> percpu allocator changes went in. So there is no need anymore to put a
> flag into each slab page. Get rid of the SlubDebug flag and use
> the flags in kmem_cache instead.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
