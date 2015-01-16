Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id D83FE6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 22:58:01 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id l6so6773607qcy.12
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 19:58:01 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id le8si4636282qcb.11.2015.01.15.19.58.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 19:58:00 -0800 (PST)
Date: Thu, 15 Jan 2015 21:57:58 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by removing
 preemption on/off
In-Reply-To: <20150115225130.00c0c99a@grimm.local.home>
Message-ID: <alpine.DEB.2.11.1501152155480.14236@gentwo.org>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com> <20150115171634.685237a4.akpm@linux-foundation.org> <20150115203045.00e9fb73@grimm.local.home> <alpine.DEB.2.11.1501152126300.13976@gentwo.org>
 <20150115225130.00c0c99a@grimm.local.home>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

> I get:
>
> 		mov    %gs:0x18(%rax),%rdx
>
> Looks to me that %gs is used.

%gs is used as a segment prefix. That does not add significant cycles.
Retrieving the content of %gs and loading it into another register would
be expensive in terms of cpu cycles.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
