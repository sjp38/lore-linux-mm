Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7BB046B005D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 10:16:26 -0400 (EDT)
Date: Wed, 3 Oct 2012 14:16:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: init_kmem_cache_cpus() and put_cpu_partial() can
 be static
In-Reply-To: <alpine.DEB.2.00.1210022154520.8723@chino.kir.corp.google.com>
Message-ID: <0000013a26fc13cf-2a85d946-fe2b-4180-a5a0-fbe6781a2934-000000@email.amazonses.com>
References: <20120928083405.GA23740@localhost> <alpine.DEB.2.00.1210022154520.8723@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Glauber Costa <glommer@parallels.com>

On Tue, 2 Oct 2012, David Rientjes wrote:

> On Fri, 28 Sep 2012, Fengguang Wu wrote:
>
> > Acked-by: Glauber Costa <glommer@parallels.com>
> > Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
>
> Acked-by: David Rientjes <rientjes@google.com>
>
> I think init_kmem_cache_cpus() would also benefit from just being inlined
> into alloc_kmem_cache_cpus().

The compiler will do that if it is advantageous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
