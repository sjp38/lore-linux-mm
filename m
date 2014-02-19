Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C54F96B0035
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 17:04:40 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so925859pde.41
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:04:40 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id xe9si935219pab.141.2014.02.19.14.04.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 14:04:39 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so987421pad.14
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:04:39 -0800 (PST)
Date: Wed, 19 Feb 2014 14:04:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <alpine.DEB.2.10.1402181033480.28964@nuc>
Message-ID: <alpine.DEB.2.02.1402191404030.31921@chino.kir.corp.google.com>
References: <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com> <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com> <alpine.DEB.2.10.1402071150090.15168@nuc> <alpine.DEB.2.10.1402071245040.20246@nuc> <20140210191321.GD1558@linux.vnet.ibm.com> <20140211074159.GB27870@lge.com> <alpine.DEB.2.10.1402121612270.8183@nuc> <20140217065257.GD3468@lge.com>
 <alpine.DEB.2.10.1402181033480.28964@nuc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Tue, 18 Feb 2014, Christoph Lameter wrote:

> Its an optimization to avoid calling the page allocator to figure out if
> there is memory available on a particular node.
> 

Thus this patch breaks with memory hot-add for a memoryless node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
