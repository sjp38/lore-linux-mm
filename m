Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id CAFF16B0036
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 10:55:50 -0500 (EST)
Received: by mail-qa0-f50.google.com with SMTP id cm18so2686785qab.9
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 07:55:50 -0800 (PST)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id d67si2013889qgf.25.2014.01.29.07.55.49
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 07:55:50 -0800 (PST)
Date: Wed, 29 Jan 2014 09:55:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] powerpc: enable CONFIG_HAVE_MEMORYLESS_NODES
In-Reply-To: <20140128183457.GA9315@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1401290955190.23856@nuc>
References: <20140128183457.GA9315@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Tue, 28 Jan 2014, Nishanth Aravamudan wrote:

> Anton Blanchard found an issue with an LPAR that had no memory in Node
> 0. Christoph Lameter recommended, as one possible solution, to use
> numa_mem_id() for locality of the nearest memory node-wise. However,
> numa_mem_id() [and the other related APIs] are only useful if
> CONFIG_HAVE_MEMORYLESS_NODES is set. This is only the case for ia64
> currently, but clearly we can have memoryless nodes on ppc64. Add the
> Kconfig option and define it to be the same value as CONFIG_NUMA.

Well this is trivial but if you need encouragement:

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
