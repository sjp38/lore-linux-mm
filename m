Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 163836B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 11:11:38 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id i8so817271qcq.36
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 08:11:37 -0800 (PST)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id r62si1285871yhc.123.2014.02.19.08.11.36
        for <linux-mm@kvack.org>;
        Wed, 19 Feb 2014 08:11:37 -0800 (PST)
Date: Wed, 19 Feb 2014 10:11:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140218222242.GA10844@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1402191010250.11318@nuc>
References: <alpine.DEB.2.10.1402071245040.20246@nuc> <20140210191321.GD1558@linux.vnet.ibm.com> <20140211074159.GB27870@lge.com> <20140213065137.GA10860@linux.vnet.ibm.com> <20140217070051.GE3468@lge.com> <alpine.DEB.2.10.1402181051560.1291@nuc>
 <20140218172832.GD31998@linux.vnet.ibm.com> <alpine.DEB.2.10.1402181356120.2910@nuc> <20140218210923.GA28170@linux.vnet.ibm.com> <alpine.DEB.2.10.1402181547210.3973@nuc> <20140218222242.GA10844@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Tue, 18 Feb 2014, Nishanth Aravamudan wrote:

> the performance impact of the underlying NUMA configuration. I guess we
> could special-case memoryless/cpuless configurations somewhat, but I
> don't think there's any reason to do that if we can make memoryless-node
> support work in-kernel?

Well we can make it work in-kernel but it always has been a bit wacky (as
is the idea of numa "memory" nodes without memory).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
