Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 15B986B0038
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 10:36:17 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id rp18so14681852iec.25
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 07:36:16 -0800 (PST)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id ht1si11249615igb.26.2014.12.17.07.36.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 07:36:15 -0800 (PST)
Date: Wed, 17 Dec 2014 09:36:13 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
In-Reply-To: <CAAmzW4NCpx5aJyW36fgOfu3EaDj6=uv6MUiBC+a0ggePWPXndQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1412170935480.2047@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141215075933.GD4898@js1304-P5Q-DELUXE> <CAAmzW4NCpx5aJyW36fgOfu3EaDj6=uv6MUiBC+a0ggePWPXndQ@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, 17 Dec 2014, Joonsoo Kim wrote:

> Ping... and I found another way to remove preempt_disable/enable
> without complex changes.
>
> What we want to ensure is getting tid and kmem_cache_cpu
> on the same cpu. We can achieve that goal with below condition loop.
>
> I ran Jesper's benchmark and saw 3~5% win in a fast-path loop over
> kmem_cache_alloc+free in CONFIG_PREEMPT.
>
> 14.5 ns -> 13.8 ns
>
> See following patch.

Good idea. How does this affect the !CONFIG_PREEMPT case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
