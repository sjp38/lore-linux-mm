Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8DEBC6B0078
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 10:06:53 -0500 (EST)
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100118150159.GB14345@redhat.com>
References: <20100118133755.GG30698@redhat.com>
	 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
	 <20100118141938.GI30698@redhat.com>
	 <20100118143232.0a0c4b4d@lxorguk.ukuu.org.uk>
	 <1263826198.4283.600.camel@laptop>  <20100118150159.GB14345@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 18 Jan 2010 16:06:34 +0100
Message-ID: <1263827194.4283.609.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-01-18 at 17:01 +0200, Gleb Natapov wrote:
> There are valid uses for mlockall()

That's debatable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
