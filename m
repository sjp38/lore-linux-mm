Subject: Re: [PATCH] update ctime and mtime for mmaped write
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <E1HJwCl-0003V6-00@dorka.pomaz.szeredi.hu>
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu>
	 <1172081562.9108.1.camel@heimdal.trondhjem.org>
	 <E1HJwCl-0003V6-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Wed, 21 Feb 2007 13:36:44 -0500
Message-Id: <1172083004.9108.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, staubach@redhat.com, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-02-21 at 19:28 +0100, Miklos Szeredi wrote:
> > > This flag is checked in msync() and __fput(), and if set, the file
> > > times are updated and the flag is cleared
> > 
> > Why not also check inside vfs_getattr?
> 
> This is the minimum, that the standard asks for.
> 
> Note, your porposal would touch the times in vfs_getattr(), which
> means, that the modification times would depend on the time of the
> last stat() call, which is not really right, though it would still be
> conforming.
> 
> It is much saner, if the modification time is always the time of the
> last write() or msync().

I disagree. The above doesn't allow a program like 'make' to discover
whether or not the file has changed by simply calling stat(). Instead,
you're forcing a call to msync()+stat().

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
