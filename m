Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2C36B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 16:25:35 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o8TKPViT005451
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:25:31 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by kpbe16.cbf.corp.google.com with ESMTP id o8TKPTwT014910
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:25:30 -0700
Received: by pzk36 with SMTP id 36so719891pzk.40
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:25:29 -0700 (PDT)
Date: Wed, 29 Sep 2010 13:25:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] slub: Move NUMA-related functions under
 CONFIG_NUMA
In-Reply-To: <1285761735-31499-3-git-send-email-namhyung@gmail.com>
Message-ID: <alpine.DEB.2.00.1009291324500.9797@chino.kir.corp.google.com>
References: <1285761735-31499-1-git-send-email-namhyung@gmail.com> <1285761735-31499-3-git-send-email-namhyung@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Namhyung Kim <namhyung@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Namhyung Kim wrote:

> Make kmalloc_cache_alloc_node_notrace(), kmalloc_large_node()
> and __kmalloc_node_track_caller() to be compiled only when
> CONFIG_NUMA is selected.
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
