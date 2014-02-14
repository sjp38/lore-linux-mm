Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 305366B0035
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 18:19:06 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so12904590pab.37
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 15:19:05 -0800 (PST)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id xu6si7333647pab.109.2014.02.14.15.19.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 15:19:04 -0800 (PST)
Received: by mail-pb0-f46.google.com with SMTP id um1so12908889pbc.19
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 15:19:04 -0800 (PST)
Date: Fri, 14 Feb 2014 15:19:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/9] slab: move up code to get kmem_cache_node in
 free_block()
In-Reply-To: <1392361043-22420-4-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1402141518400.13935@chino.kir.corp.google.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Joonsoo Kim wrote:

> node isn't changed, so we don't need to retreive this structure
> everytime we move the object. Maybe compiler do this optimization,
> but making it explicitly is better.
> 

Would it be possible to make it const struct kmem_cache_node *n then?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
