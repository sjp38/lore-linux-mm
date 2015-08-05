Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6746B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 13:06:54 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so34409054qge.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 10:06:53 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id c66si6245607qgf.109.2015.08.05.10.06.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 10:06:53 -0700 (PDT)
Date: Wed, 5 Aug 2015 12:06:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
In-Reply-To: <461E8600-5A4C-44DD-A108-4A5C2FA5BAD3@rjmx.net>
Message-ID: <alpine.DEB.2.11.1508051205510.30033@east.gentwo.org>
References: <55C18D2E.4030009@rjmx.net> <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org> <461E8600-5A4C-44DD-A108-4A5C2FA5BAD3@rjmx.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ron Murray <rjmx@rjmx.net>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 5 Aug 2015, Ron Murray wrote:

> I'll try the command-line option and see what I get. I thought about memory corruption, so ran memtest86 for a few hours with no errors (whatever that's worth).

It could be corruption due to an errand pointer value. memory testing will
not catch that. slub_debug will perform validation of pointers and basic
integrity checks on slab objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
