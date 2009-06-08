Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 670256B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 11:22:21 -0400 (EDT)
In-reply-to: <20090608162913.GL8633@ZenIV.linux.org.uk> (message from Al Viro
	on Mon, 8 Jun 2009 17:29:13 +0100)
Subject: Re: [PATCH 0/23] File descriptor hot-unplug support v2
References: <m1skkf761y.fsf@fess.ebiederm.org> <m1oct739xu.fsf@fess.ebiederm.org> <20090606080334.GA15204@ZenIV.linux.org.uk> <E1MDbLz-0003wm-Db@pomaz-ex.szeredi.hu> <20090608162913.GL8633@ZenIV.linux.org.uk>
Message-Id: <E1MDhxh-0004nz-Qm@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 08 Jun 2009 18:44:41 +0200
Sender: owner-linux-mm@kvack.org
To: viro@ZenIV.linux.org.uk
Cc: miklos@szeredi.hu, ebiederm@xmission.com, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hugh@veritas.com, tj@kernel.org, adobriyan@gmail.com, torvalds@linux-foundation.org, alan@lxorguk.ukuu.org.uk, gregkh@suse.de, npiggin@suse.de, akpm@linux-foundation.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jun 2009, Al Viro wrote:
> On Mon, Jun 08, 2009 at 11:41:19AM +0200, Miklos Szeredi wrote:
> > On Sat, 6 Jun 2009, Al Viro wrote:
> > > Frankly, I very much suspect that force-umount is another case like that;
> > > we'll need a *lot* of interesting cooperation from fs for that to work and
> > > to be useful.  I'd be delighted to be proven incorrect on that one, so
> > > if you have anything serious in that direction, please share the details.
> > 
> > Umm, not sure why we'd need cooperation from the fs.  Simply wait for
> > the operation to exit the filesystem or driver.  If it's a blocking
> > operation, send a signal to interrupt it.
> 
> And making sure that operations *are* interruptible (and that we can cope
> with $BIGNUM new failure exits correctly) does not qualify as cooperation?

I'm still not getting what the problem is.  AFAICS file operations are
either

 a) non-interruptible but finish within a short time or
 b) may block indefinitely but are interruptible (or at least killable).

Anything else is already problematic, resulting in processes "stuck in
D state".

Can you give a more concrete example about your worries?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
