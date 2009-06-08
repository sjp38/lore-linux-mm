Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E666C6B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 04:32:22 -0400 (EDT)
In-reply-to: <20090606080334.GA15204@ZenIV.linux.org.uk> (message from Al Viro
	on Sat, 6 Jun 2009 09:03:34 +0100)
Subject: Re: [PATCH 0/23] File descriptor hot-unplug support v2
References: <m1skkf761y.fsf@fess.ebiederm.org> <m1oct739xu.fsf@fess.ebiederm.org> <20090606080334.GA15204@ZenIV.linux.org.uk>
Message-Id: <E1MDbLz-0003wm-Db@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 08 Jun 2009 11:41:19 +0200
Sender: owner-linux-mm@kvack.org
To: viro@ZenIV.linux.org.uk
Cc: ebiederm@xmission.com, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hugh@veritas.com, tj@kernel.org, adobriyan@gmail.com, torvalds@linux-foundation.org, alan@lxorguk.ukuu.org.uk, gregkh@suse.de, npiggin@suse.de, akpm@linux-foundation.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Jun 2009, Al Viro wrote:
> Frankly, I very much suspect that force-umount is another case like that;
> we'll need a *lot* of interesting cooperation from fs for that to work and
> to be useful.  I'd be delighted to be proven incorrect on that one, so
> if you have anything serious in that direction, please share the details.

Umm, not sure why we'd need cooperation from the fs.  Simply wait for
the operation to exit the filesystem or driver.  If it's a blocking
operation, send a signal to interrupt it.

Sure, filesystems and drivers have lots of state, but we don't need to
care about that, just like we don't need to care about it for
remounting read-only.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
