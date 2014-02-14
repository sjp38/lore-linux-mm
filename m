Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1969C6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 13:46:19 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so19017469qae.10
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:46:18 -0800 (PST)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id 39si4440204qgx.191.2014.02.14.10.46.18
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 10:46:18 -0800 (PST)
Date: Fri, 14 Feb 2014 12:46:16 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 6/9] slab: introduce alien_cache
In-Reply-To: <1392361043-22420-7-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1402141245520.12887@nuc>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-7-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Joonsoo Kim wrote:

> Currently, we use array_cache for alien_cache. Although they are mostly
> similar, there is one difference, that is, need for spinlock.
> We don't need spinlock for array_cache itself, but to use array_cache for
> alien_cache, array_cache structure should have spinlock. This is needless
> overhead, so removing it would be better. This patch prepare it by
> introducing alien_cache and using it. In the following patch,
> we remove spinlock in array_cache.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
