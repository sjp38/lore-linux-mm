Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 657776B0095
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 11:49:37 -0500 (EST)
Date: Thu, 4 Mar 2010 09:37:55 -0700
Message-Id: <201003041637.o24GbtJX005739@alien.loup.net>
From: Mike Hayward <hayward@loup.net>
In-reply-to: <f875e2fe1003040458o3e13de97v3d839482939b687b@mail.gmail.com>
	(message from foo saa on Thu, 4 Mar 2010 07:58:07 -0500)
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org> <f875e2fe1003040458o3e13de97v3d839482939b687b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: foosaa@gmail.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I always take it for granted, but forgot to mention, you should also
use O_DIRECT to bypass the linux buffer cache.  It often gets in the
way of error propagation since it is changing your io requests into
it's own page sized ios and will also "lie" to you about having
written your data in the first place since it's a write back cache.

The point is you have to disable all the caches everywhere or the
error information will get absorbed by the caches.

- Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
