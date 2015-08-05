Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8033B6B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 15:06:25 -0400 (EDT)
Received: by igr7 with SMTP id 7so101598722igr.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 12:06:25 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id u65si3215397ioi.29.2015.08.05.12.06.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 12:06:24 -0700 (PDT)
Date: Wed, 5 Aug 2015 14:06:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
In-Reply-To: <81C750EC-F4D4-4890-894A-1D92E5CF3A31@rjmx.net>
Message-ID: <alpine.DEB.2.11.1508051405130.30653@east.gentwo.org>
References: <55C18D2E.4030009@rjmx.net> <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org> <20150805162436.GD25159@twins.programming.kicks-ass.net> <81C750EC-F4D4-4890-894A-1D92E5CF3A31@rjmx.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ron Murray <rjmx@rjmx.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>

On Wed, 5 Aug 2015, Ron Murray wrote:

> I will try re-compiling to use the SLAB allocator and see if that helps.

The slab allocator does not have the same diagnostic capabilities to
detect the memory corruption issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
