Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id D069D6B006C
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 10:41:52 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id hn18so749022igb.1
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 07:41:52 -0700 (PDT)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id e4si2335336igx.10.2014.10.24.07.41.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 07:41:51 -0700 (PDT)
Date: Fri, 24 Oct 2014 09:41:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/4] [RFC] slub: Fastpath optimization (especially for
 RT)
In-Reply-To: <20141024045630.GD15243@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1410240938460.29214@gentwo.org>
References: <20141022155517.560385718@linux.com> <20141023080942.GA7598@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1410230916090.19494@gentwo.org> <20141024045630.GD15243@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

> I found that you said retrieving tid first is sufficient to do
> things right in old discussion. :)

Right but the tid can be obtained from a different processor.


One other aspect of this patchset is that it reduces the cache footprint
of the alloc and free functions. This typically results in a performance
increase for the allocator. If we can avoid the page_address() and
virt_to_head_page() stuff that is required because we drop the ->page
field in a sufficient number of places then this may be a benefit that
goes beyond the RT and CONFIG_PREEMPT case.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
