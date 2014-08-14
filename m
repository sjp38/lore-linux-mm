Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA5D6B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 10:35:42 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id hy10so1485902vcb.18
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 07:35:42 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id j110si7266446qgf.122.2014.08.14.07.35.40
        for <linux-mm@kvack.org>;
        Thu, 14 Aug 2014 07:35:41 -0700 (PDT)
Date: Thu, 14 Aug 2014 09:35:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH v3 1/4] topology: add support for node_to_mem_node()
 to determine the fallback node
In-Reply-To: <20140814001422.GJ11121@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1408140934290.25902@gentwo.org>
References: <20140814001301.GI11121@linux.vnet.ibm.com> <20140814001422.GJ11121@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On Wed, 13 Aug 2014, Nishanth Aravamudan wrote:

> +++ b/include/linux/topology.h
> @@ -119,11 +119,20 @@ static inline int numa_node_id(void)
>   * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
>   */
>  DECLARE_PER_CPU(int, _numa_mem_);
> +extern int _node_numa_mem_[MAX_NUMNODES];

Why are these variables starting with an _ ?
Maybe _numa_mem was defined that way because it is typically not defined.
We dont do this in other situations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
