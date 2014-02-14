Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 693E56B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 18:15:55 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so12899329pbc.24
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 15:15:55 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id l8si7294185paa.257.2014.02.14.15.15.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 15:15:54 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so12876384pab.16
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 15:15:53 -0800 (PST)
Date: Fri, 14 Feb 2014 15:15:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/9] slab: add unlikely macro to help compiler
In-Reply-To: <1392361043-22420-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1402141515340.13935@chino.kir.corp.google.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Joonsoo Kim wrote:

> slab_should_failslab() is called on every allocation, so to optimize it
> is reasonable. We normally don't allocate from kmem_cache. It is just
> used when new kmem_cache is created, so it's very rare case. Therefore,
> add unlikely macro to help compiler optimization.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
