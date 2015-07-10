Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 406246B025D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 15:22:23 -0400 (EDT)
Received: by igpy18 with SMTP id y18so20025975igp.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 12:22:23 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id m30si2698092iod.140.2015.07.10.12.22.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jul 2015 12:22:22 -0700 (PDT)
Date: Fri, 10 Jul 2015 14:22:21 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] mm/slub: Move slab initialization into irq enabled
 region
In-Reply-To: <20150710110242.25c84965@gandalf.local.home>
Message-ID: <alpine.DEB.2.11.1507101421570.32416@east.gentwo.org>
References: <20150710120259.836414367@linutronix.de> <20150710110242.25c84965@gandalf.local.home>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Fri, 10 Jul 2015, Steven Rostedt wrote:

> And get rid of the double check for !page in the fast path.

This is the 2nd of 3 checks by the way. Both our approaches together get
it down to 1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
