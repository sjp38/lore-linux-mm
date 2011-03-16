Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7BF378D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 16:51:41 -0400 (EDT)
Date: 16 Mar 2011 16:51:39 -0400
Message-ID: <20110316205139.2035.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 5/8] mm/slub: Factor out some common code.
In-Reply-To: <alpine.DEB.2.00.1103161308410.11002@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, rientjes@google.com
Cc: herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, penberg@cs.helsinki.fi

> Where's your signed-off-by?

Somewhere under the pile of crap on my desk. :-)
(More to the point, waiting for me to think it's good enough to submit
For Real.)

> Nice cleanup.
> 
> "flag" should be unsigned long in all of these functions: the constants 
> are declared with UL suffixes in slab.h.

Actually, I did that deliberately.  Because there's a problem I keep
wondering about, which repeats many many times in the kernel:

*Why* are they unsigned long?  That's an awkward type: 32 bits on many
architectures, so we can't portably assign more than 32 bits, and on
platforms where it's 64 bits, the upper 32 are just wasting space.
(And REX prefixes on x86-64.)

Wouldn't it be a better cleanup to convert the whole lot to unsigned
or u32?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
