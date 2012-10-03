Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id C1D996B005D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 00:55:13 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so10791893pbb.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 21:55:13 -0700 (PDT)
Date: Tue, 2 Oct 2012 21:55:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: init_kmem_cache_cpus() and put_cpu_partial() can
 be static
In-Reply-To: <20120928083405.GA23740@localhost>
Message-ID: <alpine.DEB.2.00.1210022154520.8723@chino.kir.corp.google.com>
References: <20120928083405.GA23740@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Glauber Costa <glommer@parallels.com>

On Fri, 28 Sep 2012, Fengguang Wu wrote:

> Acked-by: Glauber Costa <glommer@parallels.com>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>

Acked-by: David Rientjes <rientjes@google.com>

I think init_kmem_cache_cpus() would also benefit from just being inlined
into alloc_kmem_cache_cpus().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
