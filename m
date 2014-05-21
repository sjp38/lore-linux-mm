Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8236B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 10:16:33 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id i17so3276709qcy.39
        for <linux-mm@kvack.org>; Wed, 21 May 2014 07:16:32 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id g62si1397361qgf.39.2014.05.21.07.16.30
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 07:16:30 -0700 (PDT)
Date: Wed, 21 May 2014 09:16:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Node 0 not necessary for powerpc?
In-Reply-To: <20140519182400.GM8941@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1405210915170.7859@gentwo.org>
References: <20140311195632.GA946@linux.vnet.ibm.com> <alpine.DEB.2.10.1403120839110.6865@nuc> <20140313164949.GC22247@linux.vnet.ibm.com> <20140519182400.GM8941@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, David Rientjes <rientjes@google.com>, benh@kernel.crashing.org, Tejun Heo <htejun@gmail.com>, tony.luck@intel.com

On Mon, 19 May 2014, Nishanth Aravamudan wrote:

> I'm seeing a panic at boot with this change on an LPAR which actually
> has no Node 0. Here's what I think is happening:
>
> start_kernel
>     ...
>     -> setup_per_cpu_areas
>         -> pcpu_embed_first_chunk
>             -> pcpu_fc_alloc
>                 -> ___alloc_bootmem_node(NODE_DATA(cpu_to_node(cpu), ...
>     -> smp_prepare_boot_cpu
>         -> set_numa_node(boot_cpuid)
>
> So we panic on the NODE_DATA call. It seems that ia64, at least, uses
> pcpu_alloc_first_chunk rather than embed. x86 has some code to handle
> early calls of cpu_to_node (early_cpu_to_node) and sets the mapping for
> all CPUs in setup_per_cpu_areas().

Maybe we can switch ia64 too embed? Tejun: Why are there these
dependencies?

> Thoughts? Does that mean we need something similar to x86 for powerpc?

Tejun is the expert in this area. CCing him.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
