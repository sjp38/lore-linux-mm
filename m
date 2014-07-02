Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 132946B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 20:34:44 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id w7so7414542lbi.39
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 17:34:44 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id 8si21075648lal.52.2014.07.01.17.34.42
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 17:34:44 -0700 (PDT)
Date: Wed, 2 Jul 2014 09:39:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 2/9] slab: move up code to get kmem_cache_node in
 free_block()
Message-ID: <20140702003952.GA9972@js1304-P5Q-DELUXE>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1404203258-8923-3-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1407011520120.4004@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407011520120.4004@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

On Tue, Jul 01, 2014 at 03:21:21PM -0700, David Rientjes wrote:
> On Tue, 1 Jul 2014, Joonsoo Kim wrote:
> 
> > node isn't changed, so we don't need to retreive this structure
> > everytime we move the object. Maybe compiler do this optimization,
> > but making it explicitly is better.
> > 
> 
> Qualifying the pointer as const would be even more explicit.

Hello,

So what you recommend is something likes below?

-       struct kmem_cache_node *n = get_node(cachep, node);
+       struct kmem_cache_node * const n = get_node(cachep, node);

I don't have seen this form of code protecting pointer itself in mm.
Instead, I have seen 'const struct kmem_cache_node *n' which protects
memory pointed by pointer. But this case isn't that case.

Am I missing something?

> 
> > Acked-by: Christoph Lameter <cl@linux.com>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
