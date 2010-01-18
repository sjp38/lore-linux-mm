Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4FA4B6B0082
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 10:14:19 -0500 (EST)
Date: Mon, 18 Jan 2010 17:14:05 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100118151405.GD14345@redhat.com>
References: <20100118133755.GG30698@redhat.com>
 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
 <20100118141938.GI30698@redhat.com>
 <20100118143232.0a0c4b4d@lxorguk.ukuu.org.uk>
 <1263826198.4283.600.camel@laptop>
 <20100118150159.GB14345@redhat.com>
 <1263827194.4283.609.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1263827194.4283.609.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 04:06:34PM +0100, Peter Zijlstra wrote:
> On Mon, 2010-01-18 at 17:01 +0200, Gleb Natapov wrote:
> > There are valid uses for mlockall()
> 
> That's debatable.
> 
Well, I have use for it. You can look at previous thread were I described
it and suggest alternatives.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
