Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 06C6B6B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:05:40 -0500 (EST)
Received: by fxm28 with SMTP id 28so1046035fxm.6
        for <linux-mm@kvack.org>; Mon, 18 Jan 2010 08:05:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100118141938.GI30698@redhat.com>
References: <20100118133755.GG30698@redhat.com>
	 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
	 <20100118141938.GI30698@redhat.com>
Date: Mon, 18 Jan 2010 18:05:38 +0200
Message-ID: <84144f021001180805q4d1203b8qab8ccb1de87b2866@mail.gmail.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 4:19 PM, Gleb Natapov <gleb@redhat.com> wrote:
> The specific use cases were discussed in the thread following previous
> version of the patch. I can describe my specific use case in a change log
> and I can copy what Andrew said about his case, but is it really needed in
> a commit message itself? It boils down to greater control over when and
> where application can get major fault. There are applications that need
> this kind of control. As of use of mlockall(MCL_FUTURE) how can I make
> sure that all memory allocated behind my application's back (by dynamic
> linker, libraries, stack) will be locked otherwise?

Again, why do you want to MCL_FUTURE but then go and use MAP_UNLOCKED?
"Greater control" is not an argument for adding a new API that needs
to be maintained forever, a real world use case is.

And yes, this stuff needs to be in the changelog. Whether you want to
spell it out or post an URL to some previous discussion is up to you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
