Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7AD6B0031
	for <linux-mm@kvack.org>; Sun,  9 Feb 2014 20:15:27 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id un15so5569057pbc.32
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 17:15:27 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id nf8si13372511pbc.30.2014.02.09.17.15.25
        for <linux-mm@kvack.org>;
        Sun, 09 Feb 2014 17:15:26 -0800 (PST)
Date: Mon, 10 Feb 2014 10:15:33 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140210011533.GB12574@lge.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
 <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.10.1402071150090.15168@nuc>
 <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140207213855.GA24989@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140207213855.GA24989@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, Feb 07, 2014 at 01:38:55PM -0800, Nishanth Aravamudan wrote:
> On 07.02.2014 [12:51:07 -0600], Christoph Lameter wrote:
> > Here is a draft of a patch to make this work with memoryless nodes.
> 
> Hi Christoph, this should be tested instead of Joonsoo's patch 2 (and 3)?

Hello,

I guess that your system has another problem that makes my patches inactive.
Maybe it will also affect to the Christoph's one. Could you confirm page_to_nid(),
numa_mem_id() and node_present_pages although I doubt mostly about page_to_nid()?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
