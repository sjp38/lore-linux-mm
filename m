Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BB1126B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 16:15:49 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o8TKFgHS023823
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:15:46 -0700
Received: from pxi11 (pxi11.prod.google.com [10.243.27.11])
	by hpaq3.eem.corp.google.com with ESMTP id o8TKFefw026185
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:15:41 -0700
Received: by pxi11 with SMTP id 11so353419pxi.20
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 13:15:40 -0700 (PDT)
Date: Wed, 29 Sep 2010 13:15:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] slub: Add lock release annotation
In-Reply-To: <1285761735-31499-2-git-send-email-namhyung@gmail.com>
Message-ID: <alpine.DEB.2.00.1009291314570.9797@chino.kir.corp.google.com>
References: <1285761735-31499-1-git-send-email-namhyung@gmail.com> <1285761735-31499-2-git-send-email-namhyung@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Namhyung Kim <namhyung@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Namhyung Kim wrote:

> The unfreeze_slab() releases page's PG_locked bit but was missing
> proper annotation. The deactivate_slab() needs to be marked also
> since it calls unfreeze_slab() without grabbing the lock.

unfreeze_slab() needs it because it calls deactivate_slab() 
unconditionally, rather.

> Signed-off-by: Namhyung Kim <namhyung@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
