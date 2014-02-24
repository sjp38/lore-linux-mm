Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id C8CFE6B0116
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 14:45:58 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id w7so7518247qcr.3
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 11:45:58 -0800 (PST)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id k67si7206446qge.14.2014.02.24.11.45.57
        for <linux-mm@kvack.org>;
        Mon, 24 Feb 2014 11:45:57 -0800 (PST)
Date: Mon, 24 Feb 2014 13:45:55 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: N_NORMAL on NUMA?
In-Reply-To: <20140221003027.GA12799@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1402241345410.20839@nuc>
References: <20140221003027.GA12799@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, anton@samba.org

On Thu, 20 Feb 2014, Nishanth Aravamudan wrote:

> I'm confused by the following:
>
> /*
>  * Array of node states.
>  */
> nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
>         [N_POSSIBLE] = NODE_MASK_ALL,
>         [N_ONLINE] = { { [0] = 1UL } },
> #ifndef CONFIG_NUMA
>         [N_NORMAL_MEMORY] = { { [0] = 1UL } },
> #ifdef CONFIG_HIGHMEM
>         [N_HIGH_MEMORY] = { { [0] = 1UL } },
> #endif
> #ifdef CONFIG_MOVABLE_NODE
>         [N_MEMORY] = { { [0] = 1UL } },
> #endif
>         [N_CPU] = { { [0] = 1UL } },
> #endif  /* NUMA */
> };
>
> Why are we checking for CONFIG_MOVABLE_NODE above when mm/Kconfig says:
>
> config MOVABLE_NODE
>         boolean "Enable to assign a node which has only movable memory"
>         depends on HAVE_MEMBLOCK
>         depends on NO_BOOTMEM
>         depends on X86_64
>         depends on NUMA
>
> ? Doesn't that mean that you can't have CONFIG_HAVE_MOVABLE_NODE without
> CONFIG_NUMA? But we're in a #ifndef CONFIG_NUMA block above...

Looks like a useless definition that can be removed then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
