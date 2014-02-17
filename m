Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCDC6B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 01:23:18 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so14881860pbb.17
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 22:23:18 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id vb2si13653656pbc.7.2014.02.16.22.23.15
        for <linux-mm@kvack.org>;
        Sun, 16 Feb 2014 22:23:17 -0800 (PST)
Date: Mon, 17 Feb 2014 15:23:24 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/9] slab: move up code to get kmem_cache_node in
 free_block()
Message-ID: <20140217062324.GC3468@lge.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1392361043-22420-4-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402141518400.13935@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402141518400.13935@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 14, 2014 at 03:19:02PM -0800, David Rientjes wrote:
> On Fri, 14 Feb 2014, Joonsoo Kim wrote:
> 
> > node isn't changed, so we don't need to retreive this structure
> > everytime we move the object. Maybe compiler do this optimization,
> > but making it explicitly is better.
> > 
> 
> Would it be possible to make it const struct kmem_cache_node *n then?

Hello, David.

Yes, it is possible.
If I send v2, I will change it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
