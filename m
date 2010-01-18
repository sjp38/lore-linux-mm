Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B3C336B0078
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 09:30:02 -0500 (EST)
Date: Mon, 18 Jan 2010 14:32:32 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100118143232.0a0c4b4d@lxorguk.ukuu.org.uk>
In-Reply-To: <20100118141938.GI30698@redhat.com>
References: <20100118133755.GG30698@redhat.com>
	<84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
	<20100118141938.GI30698@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> this kind of control. As of use of mlockall(MCL_FUTURE) how can I make
> sure that all memory allocated behind my application's back (by dynamic
> linker, libraries, stack) will be locked otherwise?

If you add this flag you can't do that anyway - some library will
helpfully start up using it and then you are completely stuffed or will
be back in two or three years adding MLOCKALL_ALWAYS.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
