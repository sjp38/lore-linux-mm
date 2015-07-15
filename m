Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id EEE9C2802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:43:06 -0400 (EDT)
Received: by igvi1 with SMTP id i1so1883126igv.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:43:06 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id uv9si146635igb.51.2015.07.15.16.43.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 16:43:06 -0700 (PDT)
Received: by iggp10 with SMTP id p10so1901442igg.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:43:06 -0700 (PDT)
Date: Wed, 15 Jul 2015 16:43:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch V2] mm/slub: Move slab initialization into irq enabled
 region
In-Reply-To: <alpine.DEB.2.11.1507102306560.5760@nanos>
Message-ID: <alpine.DEB.2.10.1507151642541.9230@chino.kir.corp.google.com>
References: <20150710120259.836414367@linutronix.de> <20150710110242.25c84965@gandalf.local.home> <alpine.DEB.2.11.1507101421570.32416@east.gentwo.org> <alpine.DEB.2.11.1507102306560.5760@nanos>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@linux.com>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Fri, 10 Jul 2015, Thomas Gleixner wrote:

> Initializing a new slab can introduce rather large latencies because
> most of the initialization runs always with interrupts disabled.
> 
> There is no point in doing so. The newly allocated slab is not visible
> yet, so there is no reason to protect it against concurrent alloc/free.
> 
> Move the expensive parts of the initialization into allocate_slab(),
> so for all allocations with GFP_WAIT set, interrupts are enabled.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Peter Zijlstra <peterz@infradead.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
