Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1F25E6B0071
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 08:19:09 -0500 (EST)
Date: Tue, 19 Jan 2010 13:21:38 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100119132138.473cf073@lxorguk.ukuu.org.uk>
In-Reply-To: <20100119120712.GM14345@redhat.com>
References: <20100118141938.GI30698@redhat.com>
	<84144f021001180805q4d1203b8qab8ccb1de87b2866@mail.gmail.com>
	<20100118170816.GA22111@redhat.com>
	<84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
	<20100118181942.GD22111@redhat.com>
	<20100118191031.0088f49a@lxorguk.ukuu.org.uk>
	<20100119071734.GG14345@redhat.com>
	<84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
	<20100119075205.GI14345@redhat.com>
	<20100119115442.131efa78@lxorguk.ukuu.org.uk>
	<20100119120712.GM14345@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > And you want millions of users to have kernels with weird extra functions
> > whole sole value is one test environment you wish to run
> > 
> We are talking about 4 lines of code that other people find useful too
> and they commented in this thread. This wouldn't be the first kernel
> feature not used by millions of people.

It wouldn't be the first completely dumb mistake in the kernel either,
but one dumb mistake doesn't argue for including others 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
