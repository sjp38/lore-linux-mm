Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 879726B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 10:02:17 -0500 (EST)
Date: Mon, 18 Jan 2010 17:01:59 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100118150159.GB14345@redhat.com>
References: <20100118133755.GG30698@redhat.com>
 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
 <20100118141938.GI30698@redhat.com>
 <20100118143232.0a0c4b4d@lxorguk.ukuu.org.uk>
 <1263826198.4283.600.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1263826198.4283.600.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 03:49:58PM +0100, Peter Zijlstra wrote:
> On Mon, 2010-01-18 at 14:32 +0000, Alan Cox wrote:
> > > this kind of control. As of use of mlockall(MCL_FUTURE) how can I make
> > > sure that all memory allocated behind my application's back (by dynamic
> > > linker, libraries, stack) will be locked otherwise?
> > 
> > If you add this flag you can't do that anyway - some library will
> > helpfully start up using it and then you are completely stuffed or will
> > be back in two or three years adding MLOCKALL_ALWAYS.
> 
> Agreed, mlockall() is a very bad interface and should not be used for a
> plethora of reasons, this being one of them.
> 
There are valid uses for mlockall() and even if the interface is bad there
is no alternative right now, so why not fix one of it problems?

> The thing is, if you cant trust your library to do sane things, then
> don't use it.
> 
Agreed, the are things that sane library should never do: exit() or output
debug info to stdio or meddle with memory mlock/munlock behind application's
back.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
