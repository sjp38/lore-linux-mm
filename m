Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 030B89003C8
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 12:32:34 -0400 (EDT)
Received: by iggf3 with SMTP id f3so36511008igg.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 09:32:33 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id a6si2837893ioa.85.2015.08.05.09.32.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 09:32:33 -0700 (PDT)
Date: Wed, 5 Aug 2015 11:32:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
In-Reply-To: <20150805162436.GD25159@twins.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.11.1508051131580.29823@east.gentwo.org>
References: <55C18D2E.4030009@rjmx.net> <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org> <20150805162436.GD25159@twins.programming.kicks-ass.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ron Murray <rjmx@rjmx.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>

On Wed, 5 Aug 2015, Peter Zijlstra wrote:

> I'll go have a look; but the obvious question is, what's the last known
> good kernel?

4.0.9 according to the original report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
