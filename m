Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 365F76B01F3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 19:55:33 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o3DNtOMN002259
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 01:55:25 +0200
Received: from pvc22 (pvc22.prod.google.com [10.241.209.150])
	by kpbe16.cbf.corp.google.com with ESMTP id o3DNtMiR026300
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:55:23 -0700
Received: by pvc22 with SMTP id 22so4296436pvc.11
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:55:22 -0700 (PDT)
Date: Tue, 13 Apr 2010 16:55:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
In-Reply-To: <u2o28c262361004131640zd034a692s4b46ee77c08e1ccd@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004131654340.8116@chino.kir.corp.google.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com> <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com> <alpine.DEB.2.00.1004131437140.8617@chino.kir.corp.google.com>
 <u2o28c262361004131640zd034a692s4b46ee77c08e1ccd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010, Minchan Kim wrote:

> This changlog is bad.
> I will change it with following as when I send v2.
> 
> "alloc_slab_page always checks nid == -1, so alloc_page_node can't be
> called with -1.
>  It means node's validity check in alloc_pages_node is unnecessary.
>  So we can use alloc_pages_exact_node instead of alloc_pages_node.
>  It could avoid comparison and branch as 6484eb3e2a81807722 tried."
> 

Each patch in this series seems to be independent and can be applied 
seperately, so it's probably not necessary to make them incremental.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
