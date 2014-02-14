Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5036D6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 13:40:01 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i17so20395199qcy.25
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:40:01 -0800 (PST)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id u90si4499111qge.3.2014.02.14.10.40.00
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 10:40:00 -0800 (PST)
Date: Fri, 14 Feb 2014 12:39:58 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/9] slab: defer slab_destroy in free_block()
In-Reply-To: <1392361043-22420-5-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1402141239010.12887@nuc>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Joonsoo Kim wrote:

> In free_block(), if freeing object makes new free slab and number of
> free_objects exceeds free_limit, we start to destroy this new free slab
> with holding the kmem_cache node lock. Holding the lock is useless and,
> generally, holding a lock as least as possible is good thing. I never
> measure performance effect of this, but we'd be better not to hold the lock
> as much as possible.

This is also good because kmem_cache_free is no longer called while
holding the node lock. So we avoid one case of recursion.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
