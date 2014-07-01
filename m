Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 856376B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 18:21:25 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so8830393iec.19
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:21:25 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id dw19si36354861icc.85.2014.07.01.15.21.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 15:21:24 -0700 (PDT)
Received: by mail-ig0-f173.google.com with SMTP id uq10so6036259igb.0
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:21:23 -0700 (PDT)
Date: Tue, 1 Jul 2014 15:21:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 2/9] slab: move up code to get kmem_cache_node in
 free_block()
In-Reply-To: <1404203258-8923-3-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1407011520120.4004@chino.kir.corp.google.com>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com> <1404203258-8923-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

On Tue, 1 Jul 2014, Joonsoo Kim wrote:

> node isn't changed, so we don't need to retreive this structure
> everytime we move the object. Maybe compiler do this optimization,
> but making it explicitly is better.
> 

Qualifying the pointer as const would be even more explicit.

> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
