Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 970216B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 02:00:44 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so14455013pde.21
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 23:00:44 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id fu1si13694511pbc.284.2014.02.16.23.00.41
        for <linux-mm@kvack.org>;
        Sun, 16 Feb 2014 23:00:43 -0800 (PST)
Date: Mon, 17 Feb 2014 16:00:51 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140217070051.GE3468@lge.com>
References: <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.10.1402071150090.15168@nuc>
 <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210191321.GD1558@linux.vnet.ibm.com>
 <20140211074159.GB27870@lge.com>
 <20140213065137.GA10860@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140213065137.GA10860@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, Feb 12, 2014 at 10:51:37PM -0800, Nishanth Aravamudan wrote:
> Hi Joonsoo,
> Also, given that only ia64 and (hopefuly soon) ppc64 can set
> CONFIG_HAVE_MEMORYLESS_NODES, does that mean x86_64 can't have
> memoryless nodes present? Even with fakenuma? Just curious.

I don't know, because I'm not expert on NUMA system :)
At first glance, fakenuma can't be used for testing
CONFIG_HAVE_MEMORYLESS_NODES. Maybe some modification is needed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
