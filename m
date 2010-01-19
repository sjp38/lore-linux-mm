Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 274C16B0071
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 06:52:14 -0500 (EST)
Date: Tue, 19 Jan 2010 11:54:42 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100119115442.131efa78@lxorguk.ukuu.org.uk>
In-Reply-To: <20100119075205.GI14345@redhat.com>
References: <20100118133755.GG30698@redhat.com>
	<84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
	<20100118141938.GI30698@redhat.com>
	<84144f021001180805q4d1203b8qab8ccb1de87b2866@mail.gmail.com>
	<20100118170816.GA22111@redhat.com>
	<84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
	<20100118181942.GD22111@redhat.com>
	<20100118191031.0088f49a@lxorguk.ukuu.org.uk>
	<20100119071734.GG14345@redhat.com>
	<84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
	<20100119075205.GI14345@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> In my case (virtualization) I want to test/profile guest under heavy swapping
> of a guests memory, so I intentionally create memory shortage by creating
> guest much large then host memory, but I want system to swap out only
> guest's memory.

So this isn't an API question this is an obscure corner case testing
question.

> 
> > 
> > It would be probably useful if you could point us to the application
> > source code that actually wants this feature.
> > 
> This is two line patch to qemu that calls mlockall(MCL_CURRENT|MCL_FUTURE)
> at the beginning of the main() and changes guest memory allocation to
> use MAP_UNLOCKED flag. All alternative solutions in this thread suggest
> that I should rewrite qemu + all library it uses. You see why I can't
> take them seriously?

And you want millions of users to have kernels with weird extra functions
whole sole value is one test environment you wish to run

See why we can't take you seriously either ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
