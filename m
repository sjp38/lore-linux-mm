Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3D79A6B007D
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 14:07:55 -0500 (EST)
Date: Mon, 18 Jan 2010 19:10:31 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
In-Reply-To: <20100118181942.GD22111@redhat.com>
References: <20100118133755.GG30698@redhat.com>
	<84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
	<20100118141938.GI30698@redhat.com>
	<84144f021001180805q4d1203b8qab8ccb1de87b2866@mail.gmail.com>
	<20100118170816.GA22111@redhat.com>
	<84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
	<20100118181942.GD22111@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> I can't realistically chase every address space mapping changes and mlock
> new areas. The only way other then mlockall() is to use custom memory
> allocator that allocates mlocked memory.

Which keeps all the special cases in your app rather than in every single
users kernel. That seems to be the right way up, especially as you can
make a library of it !

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
