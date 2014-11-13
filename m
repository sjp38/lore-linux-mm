Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 26F706B00DF
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 15:07:11 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id i50so10877057qgf.33
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 12:07:10 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id z3si48020905qaj.112.2014.11.13.12.07.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 12:07:09 -0800 (PST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 13 Nov 2014 13:07:08 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C40DD19D8040
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 12:55:47 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sADK76aL57737304
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 21:07:06 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id sADKBsvs024323
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 13:11:57 -0700
Date: Thu, 13 Nov 2014 12:07:01 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/16] Replace smp_read_barrier_depends() with
 lockless_derefrence()
Message-ID: <20141113200701.GP4460@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pranith Kumar <bobby.prani@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Cristian Stoica <cristian.stoica@freescale.com>, Horia Geanta <horia.geanta@freescale.com>, Ruchika Gupta <ruchika.gupta@freescale.com>, Michael Neuling <mikey@neuling.org>, Wolfram Sang <wsa@the-dreams.de>, "open list:CRYPTO API" <linux-crypto@vger.kernel.org>, open list <linux-kernel@vger.kernel.org>, Vinod Koul <vinod.koul@intel.com>, Dan Williams <dan.j.williams@intel.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Manuel =?iso-8859-1?Q?Sch=F6lling?= <manuel.schoelling@gmx.de>, Dave Jiang <dave.jiang@intel.com>, Rashika <rashika.kheria@gmail.com>, "open list:DMA GENERIC OFFLO..." <dmaengine@vger.kernel.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, "open list:Hyper-V CORE AND..." <devel@linuxdriverproject.org>, Josh Triplett <josh@joshtriplett.org>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Will Drewry <wad@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, NeilBrown <neilb@suse.de>, Joerg Roedel <jroedel@suse.de>, Sasha Levin <sasha.levin@oracle.com>, Paul McQuade <paulmcquad@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, "open list:NETWORKING [IPv4/..." <netdev@vger.kernel.org>

On Thu, Nov 13, 2014 at 02:24:06PM -0500, Pranith Kumar wrote:
> Recently lockless_dereference() was added which can be used in place of
> hard-coding smp_read_barrier_depends(). 
> 
> http://lkml.iu.edu/hypermail/linux/kernel/1410.3/04561.html
> 
> The following series tries to do this.
> 
> There are still some hard-coded locations which I was not sure how to replace
> with. I will send in separate patches/questions regarding them.

Thank you for taking this on!  Some questions and comments in response
to the individual patches.

							Thanx, Paul

> Pranith Kumar (16):
>   crypto: caam - Remove unnecessary smp_read_barrier_depends()
>   doc: memory-barriers.txt: Document use of lockless_dereference()
>   drivers: dma: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   dcache: Replace smp_read_barrier_depends() with lockless_dereference()
>   overlayfs: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   assoc_array: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   hyperv: Replace smp_read_barrier_depends() with lockless_dereference()
>   rcupdate: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   percpu: Replace smp_read_barrier_depends() with lockless_dereference()
>   perf: Replace smp_read_barrier_depends() with lockless_dereference()
>   seccomp: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   task_work: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   ksm: Replace smp_read_barrier_depends() with lockless_dereference()
>   slab: Replace smp_read_barrier_depends() with lockless_dereference()
>   netfilter: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   rxrpc: Replace smp_read_barrier_depends() with lockless_dereference()
> 
>  Documentation/memory-barriers.txt |  2 +-
>  drivers/crypto/caam/jr.c          |  3 ---
>  drivers/dma/ioat/dma_v2.c         |  3 +--
>  drivers/dma/ioat/dma_v3.c         |  3 +--
>  fs/dcache.c                       |  7 ++-----
>  fs/overlayfs/super.c              |  4 +---
>  include/linux/assoc_array_priv.h  | 11 +++++++----
>  include/linux/hyperv.h            |  9 ++++-----
>  include/linux/percpu-refcount.h   |  4 +---
>  include/linux/rcupdate.h          | 10 +++++-----
>  kernel/events/core.c              |  3 +--
>  kernel/events/uprobes.c           |  8 ++++----
>  kernel/seccomp.c                  |  7 +++----
>  kernel/task_work.c                |  3 +--
>  lib/assoc_array.c                 |  7 -------
>  mm/ksm.c                          |  7 +++----
>  mm/slab.h                         |  6 +++---
>  net/ipv4/netfilter/arp_tables.c   |  3 +--
>  net/ipv4/netfilter/ip_tables.c    |  3 +--
>  net/ipv6/netfilter/ip6_tables.c   |  3 +--
>  net/rxrpc/ar-ack.c                | 22 +++++++++-------------
>  security/keys/keyring.c           |  6 ------
>  22 files changed, 50 insertions(+), 84 deletions(-)
> 
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
