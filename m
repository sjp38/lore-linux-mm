Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0645C6B0080
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 13:31:57 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id y20so7410570ier.32
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 10:31:56 -0800 (PST)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id t11si1545305igd.28.2014.12.12.10.31.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 10:31:55 -0800 (PST)
Date: Fri, 12 Dec 2014 12:31:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
In-Reply-To: <20141212113909.6747e273@redhat.com>
Message-ID: <alpine.DEB.2.11.1412121230450.27051@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141211183758.22e224a0@redhat.com> <20141212113909.6747e273@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Alexander Duyck <alexander.h.duyck@redhat.com>

On Fri, 12 Dec 2014, Jesper Dangaard Brouer wrote:

> Crash/OOM during IP-forwarding network overload test[1] with pktgen,
> single flow thus activating a single CPU on target (device under test).

Hmmm... Bisected it and the patch that removes the page pointer from
kmem_cache_cpu causes in a memory leak. Pretty obvious with hackbench.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
