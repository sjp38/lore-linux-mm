Date: Wed, 18 Apr 2007 09:17:19 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Show slab memory usage on OOM and SysRq-M
In-Reply-To: <20070417171213.e3cbc260.dada1@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0704180915520.11160@sbz-30.cs.Helsinki.FI>
References: <4624C3C1.9040709@sw.ru> <84144f020704170622h2b16f0f6m47ffdbb3b5686758@mail.gmail.com>
 <20070417171213.e3cbc260.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Pavel Emelianov <xemul@sw.ru>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, devel@openvz.org, Kirill Korotaev <dev@openvz.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Apr 2007, Eric Dumazet wrote:
> This nr_pages should be in struct kmem_list3, not in struct kmem_cache, 
> or else you defeat NUMA optimizations if touching a field in kmem_cache 
> at kmem_getpages()/kmem_freepages() time.

We already touch ->flags, ->gfpflags, and ->gfporder in kmem_getpages(). 
Sorry for my ignorance, but how is this different?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
