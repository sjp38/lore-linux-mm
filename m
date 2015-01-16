Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id BE3CD6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 22:28:28 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id at20so18758127iec.5
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 19:28:28 -0800 (PST)
Received: from resqmta-po-03v.sys.comcast.net (resqmta-po-03v.sys.comcast.net. [2001:558:fe16:19:96:114:154:162])
        by mx.google.com with ESMTPS id l81si2738767iod.48.2015.01.15.19.28.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 19:28:27 -0800 (PST)
Date: Thu, 15 Jan 2015 21:28:26 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by removing
 preemption on/off
In-Reply-To: <20150115171634.685237a4.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1501152127220.13976@gentwo.org>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com> <20150115171634.685237a4.akpm@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>

On Thu, 15 Jan 2015, Andrew Morton wrote:

> > I saw roughly 5% win in a fast-path loop over kmem_cache_alloc/free
> > in CONFIG_PREEMPT. (14.821 ns -> 14.049 ns)
>
> I'm surprised.  preempt_disable/enable are pretty fast.  I wonder why
> this makes a measurable difference.  Perhaps preempt_enable()'s call to
> preempt_schedule() added pain?

The rest of the fastpath is already highly optimized. That is why
something like preempt enable/disable has such a disproportionate effect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
