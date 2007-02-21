In-reply-to: <1172081562.9108.1.camel@heimdal.trondhjem.org> (message from
	Trond Myklebust on Wed, 21 Feb 2007 13:12:42 -0500)
Subject: Re: [PATCH] update ctime and mtime for mmaped write
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu> <1172081562.9108.1.camel@heimdal.trondhjem.org>
Message-Id: <E1HJwCl-0003V6-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 21 Feb 2007 19:28:39 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: trond.myklebust@fys.uio.no
Cc: akpm@linux-foundation.org, staubach@redhat.com, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > This flag is checked in msync() and __fput(), and if set, the file
> > times are updated and the flag is cleared
> 
> Why not also check inside vfs_getattr?

This is the minimum, that the standard asks for.

Note, your porposal would touch the times in vfs_getattr(), which
means, that the modification times would depend on the time of the
last stat() call, which is not really right, though it would still be
conforming.

It is much saner, if the modification time is always the time of the
last write() or msync().

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
