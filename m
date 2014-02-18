Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 601FE6B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 11:57:13 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so23470054qae.38
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 08:57:13 -0800 (PST)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id a8si10661930qak.80.2014.02.18.08.57.12
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 08:57:12 -0800 (PST)
Date: Tue, 18 Feb 2014 10:57:09 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140217070051.GE3468@lge.com>
Message-ID: <alpine.DEB.2.10.1402181051560.1291@nuc>
References: <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com> <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com> <alpine.DEB.2.10.1402071150090.15168@nuc> <alpine.DEB.2.10.1402071245040.20246@nuc> <20140210191321.GD1558@linux.vnet.ibm.com> <20140211074159.GB27870@lge.com> <20140213065137.GA10860@linux.vnet.ibm.com>
 <20140217070051.GE3468@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Mon, 17 Feb 2014, Joonsoo Kim wrote:

> On Wed, Feb 12, 2014 at 10:51:37PM -0800, Nishanth Aravamudan wrote:
> > Hi Joonsoo,
> > Also, given that only ia64 and (hopefuly soon) ppc64 can set
> > CONFIG_HAVE_MEMORYLESS_NODES, does that mean x86_64 can't have
> > memoryless nodes present? Even with fakenuma? Just curious.

x86_64 currently does not support memoryless nodes otherwise it would
have set CONFIG_HAVE_MEMORYLESS_NODES in the kconfig. Memoryless nodes are
a bit strange given that the NUMA paradigm is to have NUMA nodes (meaning
memory) with processors. MEMORYLESS nodes means that we have a fake NUMA
node without memory but just processors. Not very efficient. Not sure why
people use these configurations.

> I don't know, because I'm not expert on NUMA system :)
> At first glance, fakenuma can't be used for testing
> CONFIG_HAVE_MEMORYLESS_NODES. Maybe some modification is needed.

Well yeah. You'd have to do some mods to enable that testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
