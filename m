Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 997AB6B005A
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 14:02:21 -0400 (EDT)
Date: Mon, 8 Jun 2009 11:01:51 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/23] File descriptor hot-unplug support v2
In-Reply-To: <20090608175018.GM8633@ZenIV.linux.org.uk>
Message-ID: <alpine.LFD.2.01.0906081100000.6847@localhost.localdomain>
References: <m1skkf761y.fsf@fess.ebiederm.org> <m1oct739xu.fsf@fess.ebiederm.org> <20090606080334.GA15204@ZenIV.linux.org.uk> <E1MDbLz-0003wm-Db@pomaz-ex.szeredi.hu> <20090608162913.GL8633@ZenIV.linux.org.uk> <E1MDhxh-0004nz-Qm@pomaz-ex.szeredi.hu>
 <20090608175018.GM8633@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Miklos Szeredi <miklos@szeredi.hu>, ebiederm@xmission.com, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hugh@veritas.com, tj@kernel.org, adobriyan@gmail.com, alan@lxorguk.ukuu.org.uk, gregkh@suse.de, npiggin@suse.de, akpm@linux-foundation.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>



On Mon, 8 Jun 2009, Al Viro wrote:
> 
> Welcome to reality...
> 
> * bread() is non-interruptible
> * so's copy_from_user()/copy_to_user()
> * IO we are stuck upon _might_ be interruptible, but by sending a signal
> to some other process

We can probably improve on these, though.

Like the copy_to/from_user thing. We might well be able to do that whole 
"if it's a fatal signal, return early" thing.

So in the _general_ case - no, we probably can't fix things. But we could 
likely at least improve in some common cases if we cared.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
