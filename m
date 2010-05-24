Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1094F6B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:09:40 -0400 (EDT)
Subject: Re: [PATCH 3/7]
 numa-x86_64-use-generic-percpu-var-numa_node_id-implementation-fix1
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20100521160240.b61d3404.akpm@linux-foundation.org>
References: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
	 <20100503150518.15039.3576.sendpatchset@localhost.localdomain>
	 <20100521160240.b61d3404.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 24 May 2010 10:09:32 -0400
Message-Id: <1274710172.13756.122.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Valdis.Kletnieks@vt.edu, Randy Dunlap <randy.dunlap@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, eric.whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-05-21 at 16:02 -0700, Andrew Morton wrote:
> On Mon, 03 May 2010 11:05:18 -0400
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > Incremental patch 1 to
> > numa-x86_64-use-generic-percpu-var-numa_node_id-implementation.patch
> > in 28apr10 mmotm.
> > 
> > Use generic percpu numa_node variable only for x86_64.
> > 
> > x86_32 will require separate support.  Not sure it's worth it.
> > 
> > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> >  arch/x86/Kconfig |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > Index: linux-2.6.34-rc5-mmotm-100428-1653/arch/x86/Kconfig
> > ===================================================================
> > --- linux-2.6.34-rc5-mmotm-100428-1653.orig/arch/x86/Kconfig
> > +++ linux-2.6.34-rc5-mmotm-100428-1653/arch/x86/Kconfig
> > @@ -1720,7 +1720,7 @@ config HAVE_ARCH_EARLY_PFN_TO_NID
> >  	depends on NUMA
> >  
> >  config USE_PERCPU_NUMA_NODE_ID
> > -	def_bool y
> > +	def_bool X86_64
> >  	depends on NUMA
> >  
> >  menu "Power management and ACPI options"
> 
> i386 allmodconfig:
> 
> In file included from include/linux/gfp.h:7,
>                  from include/linux/kmod.h:22,
>                  from include/linux/module.h:13,
>                  from include/linux/crypto.h:21,
>                  from arch/x86/kernel/asm-offsets_32.c:7,
>                  from arch/x86/kernel/asm-offsets.c:2:
> include/linux/topology.h: In function 'numa_node_id':
> include/linux/topology.h:248: error: implicit declaration of function 'cpu_to_node'
> 
> this patchset has been quite a PITA.  What happened?

"fix3" to numa-x86_64-use-generic-percpu-var-numa_node_id-implementation
that I send out on May 17 should have fixed this.  That was in response
to Randy's NumaQ config that pulled the same error.  He verified that it
fixed the error.

You asked about the fix3 patch [offlist] on Wednesday, 19May.  Do you
have that one in your tree?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
