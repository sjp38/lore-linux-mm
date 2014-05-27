Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id EBDBB6B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 19:56:35 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hl10so1774869igb.9
        for <linux-mm@kvack.org>; Tue, 27 May 2014 16:56:35 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id ky11si29455986icb.93.2014.05.27.16.56.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 27 May 2014 16:56:35 -0700 (PDT)
Message-ID: <1401234974.8262.8.camel@pasglop>
Subject: Re: [RFC PATCH v2 1/2] powerpc: numa: enable USE_PERCPU_NUMA_NODE_ID
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 28 May 2014 09:56:14 +1000
In-Reply-To: <20140527234420.GE4104@linux.vnet.ibm.com>
References: <20140516233945.GI8941@linux.vnet.ibm.com>
	 <20140519181423.GL8941@linux.vnet.ibm.com>
	 <20140527234420.GE4104@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org

On Tue, 2014-05-27 at 16:44 -0700, Nishanth Aravamudan wrote:
> > Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> 
> Ping on this and patch 2/2. Ben, would you be willing to pull these
> into
> your -next branch so they'd get some testing?
> 
> http://patchwork.ozlabs.org/patch/350368/
> http://patchwork.ozlabs.org/patch/349838/
> 
> Without any further changes, these two help quite a bit with the slab
> consumption on CONFIG_SLUB kernels when memoryless nodes are present.

I don't mind at all :-) I haven't really been following that story
so I was waiting for the dust to settle and maybe acks from MM people
but if you tell me they are good I'm prepared to trust you.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
