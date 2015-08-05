Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 18F9E6B0253
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 15:34:39 -0400 (EDT)
Received: by iodd187 with SMTP id d187so59763295iod.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 12:34:38 -0700 (PDT)
Received: from resqmta-po-10v.sys.comcast.net (resqmta-po-10v.sys.comcast.net. [2001:558:fe16:19:96:114:154:169])
        by mx.google.com with ESMTPS id rs8si4992554igb.99.2015.08.05.12.34.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 12:34:38 -0700 (PDT)
Date: Wed, 5 Aug 2015 14:34:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
In-Reply-To: <12261B75-F5F5-4332-A7E9-490251E4DC37@rjmx.net>
Message-ID: <alpine.DEB.2.11.1508051431570.30889@east.gentwo.org>
References: <55C18D2E.4030009@rjmx.net> <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org> <20150805162436.GD25159@twins.programming.kicks-ass.net> <81C750EC-F4D4-4890-894A-1D92E5CF3A31@rjmx.net> <alpine.DEB.2.11.1508051405130.30653@east.gentwo.org>
 <12261B75-F5F5-4332-A7E9-490251E4DC37@rjmx.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ron Murray <rjmx@rjmx.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>

On Wed, 5 Aug 2015, Ron Murray wrote:

> True. But if I don't get a crash with it, it might tell us whether the
> fault lies with SLUB or not. And I will still try with SLUB and the
> debug option (probably tonight, after I get home).

What fails is the check for a pointer to valid slab page on kfree. That
pointer was handed to the allocator.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
