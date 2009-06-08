Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0CE6B004F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 05:14:24 -0400 (EDT)
Date: Mon, 8 Jun 2009 11:24:49 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH 0/23] File descriptor hot-unplug support v2
Message-ID: <20090608102449.GB25684@shareable.org>
References: <m1skkf761y.fsf@fess.ebiederm.org> <m1oct739xu.fsf@fess.ebiederm.org> <20090606080334.GA15204@ZenIV.linux.org.uk> <E1MDbLz-0003wm-Db@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1MDbLz-0003wm-Db@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: viro@ZenIV.linux.org.uk, ebiederm@xmission.com, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hugh@veritas.com, tj@kernel.org, adobriyan@gmail.com, torvalds@linux-foundation.org, alan@lxorguk.ukuu.org.uk, gregkh@suse.de, npiggin@suse.de, akpm@linux-foundation.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi wrote:
> On Sat, 6 Jun 2009, Al Viro wrote:
> > Frankly, I very much suspect that force-umount is another case like that;
> > we'll need a *lot* of interesting cooperation from fs for that to work and
> > to be useful.  I'd be delighted to be proven incorrect on that one, so
> > if you have anything serious in that direction, please share the details.
> 
> Umm, not sure why we'd need cooperation from the fs.  Simply wait for
> the operation to exit the filesystem or driver.  If it's a blocking
> operation, send a signal to interrupt it.

We could even include the internal signal in TASK_KILLABLE, so it
interrupts otherwise uninterruptible operations.

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
