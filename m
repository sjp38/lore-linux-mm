Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id C8E6C6B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 17:27:51 -0400 (EDT)
Received: by qget71 with SMTP id t71so135184513qge.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 14:27:51 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id h1si12060923qhc.6.2015.07.10.14.27.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jul 2015 14:27:50 -0700 (PDT)
Date: Fri, 10 Jul 2015 16:27:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch V2] mm/slub: Move slab initialization into irq enabled
 region
In-Reply-To: <alpine.DEB.2.11.1507102306560.5760@nanos>
Message-ID: <alpine.DEB.2.11.1507101627320.17809@east.gentwo.org>
References: <20150710120259.836414367@linutronix.de> <20150710110242.25c84965@gandalf.local.home> <alpine.DEB.2.11.1507101421570.32416@east.gentwo.org> <alpine.DEB.2.11.1507102306560.5760@nanos>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Peter Zijlstra <peterz@infradead.org>


Acked-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
