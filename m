Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B36166B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:51:18 -0500 (EST)
Date: Thu, 4 Mar 2010 12:47:12 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH/RFC 3/8] numa:  x86_64:  use generic percpu var for
 numa_node_id() implementation
In-Reply-To: <20100304170716.10606.24477.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1003041245280.21776@router.home>
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain> <20100304170716.10606.24477.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 4 Mar 2010, Lee Schermerhorn wrote:

> Index: linux-2.6.33-mmotm-100302-1838/arch/x86/include/asm/percpu.h
> ===================================================================
> --- linux-2.6.33-mmotm-100302-1838.orig/arch/x86/include/asm/percpu.h
> +++ linux-2.6.33-mmotm-100302-1838/arch/x86/include/asm/percpu.h
> @@ -208,10 +208,12 @@ do {									\
>  #define percpu_or(var, val)		percpu_to_op("or", var, val)
>  #define percpu_xor(var, val)		percpu_to_op("xor", var, val)
>
> +#define __this_cpu_read(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
>  #define __this_cpu_read_1(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
>  #define __this_cpu_read_2(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
>  #define __this_cpu_read_4(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
>
> +#define __this_cpu_write(pcp, val)	percpu_to_op("mov", (pcp), val)
>  #define __this_cpu_write_1(pcp, val)	percpu_to_op("mov", (pcp), val)
>  #define __this_cpu_write_2(pcp, val)	percpu_to_op("mov", (pcp), val)
>  #define __this_cpu_write_4(pcp, val)	percpu_to_op("mov", (pcp), val)


The functions added are already defined in linux/percpu.h and their
definition here is wrong since the u64 case is not handled (percpu.h does
that correctly).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
