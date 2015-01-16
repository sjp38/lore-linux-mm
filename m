Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 839F76B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 22:27:20 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id b16so1487293igk.3
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 19:27:20 -0800 (PST)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id p9si5643247icc.49.2015.01.15.19.27.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 19:27:19 -0800 (PST)
Date: Thu, 15 Jan 2015 21:27:14 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by removing
 preemption on/off
In-Reply-To: <20150115203045.00e9fb73@grimm.local.home>
Message-ID: <alpine.DEB.2.11.1501152126300.13976@gentwo.org>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com> <20150115171634.685237a4.akpm@linux-foundation.org> <20150115203045.00e9fb73@grimm.local.home>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Thu, 15 Jan 2015, Steven Rostedt wrote:

> profiling function tracing I discovered that accessing preempt_count
> was actually quite expensive, even just to read. But it may not be as
> bad since Peter Zijlstra converted preempt_count to a per_cpu variable.
> Although, IIRC, the perf profiling showed the access to the %gs
> register was where the time consuming was happening, which is what
> I believe per_cpu variables still use.

The %gs register is not used since the address of the per cpu area is
available as one of the first fields in the per cpu areas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
