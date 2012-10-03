Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id AC4A16B005A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 14:21:22 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so11597235pbb.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2012 11:21:21 -0700 (PDT)
Date: Wed, 3 Oct 2012 11:21:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: init_kmem_cache_cpus() and put_cpu_partial() can
 be static
In-Reply-To: <0000013a26fc13cf-2a85d946-fe2b-4180-a5a0-fbe6781a2934-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1210031119290.2412@chino.kir.corp.google.com>
References: <20120928083405.GA23740@localhost> <alpine.DEB.2.00.1210022154520.8723@chino.kir.corp.google.com> <0000013a26fc13cf-2a85d946-fe2b-4180-a5a0-fbe6781a2934-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Glauber Costa <glommer@parallels.com>

On Wed, 3 Oct 2012, Christoph Lameter wrote:

> > > Acked-by: Glauber Costa <glommer@parallels.com>
> > > Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> >
> > Acked-by: David Rientjes <rientjes@google.com>
> >
> > I think init_kmem_cache_cpus() would also benefit from just being inlined
> > into alloc_kmem_cache_cpus().
> 
> The compiler will do that if it is advantageous.
> 

Which it obviously does with -O2, but I think it would be advantageous to 
do this at the source code level as well since we have a function with a 
single caller, which happens to be marked inline itself, but we're not 
inline.  It seems cleaner to me, but it's only a suggestion.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
