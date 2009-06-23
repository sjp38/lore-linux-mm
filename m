Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F26686B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 18:08:25 -0400 (EDT)
Date: Wed, 24 Jun 2009 01:10:07 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: kmemleak: Early log buffer exceeded
Message-ID: <20090623221007.GB9502@localdomain.by>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>2. When (crt_early_log >= ARRAY_SIZE(early_log)) == 1 we just can see stack.
>Since we have "full" early_log maybe it'll be helpfull to see it?

Sorry, sent you wrong message. Right one has no 'to see it' part.
I meant 'to do something more than just print stack'.

	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
