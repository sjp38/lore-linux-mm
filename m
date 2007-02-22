Subject: Re: [PATCH] update ctime and mtime for mmaped write
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <E1HKKrL-0006k6-00@dorka.pomaz.szeredi.hu>
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu>
	 <20070221202615.a0a167f4.akpm@linux-foundation.org>
	 <E1HK8hU-0005Mq-00@dorka.pomaz.szeredi.hu> <45DDD55F.4060106@redhat.com>
	 <E1HKIN1-0006RX-00@dorka.pomaz.szeredi.hu> <45DDF9C1.4090003@redhat.com>
	 <E1HKKrL-0006k6-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Thu, 22 Feb 2007 16:04:13 -0500
Message-Id: <1172178253.6382.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: staubach@redhat.com, akpm@linux-foundation.org, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-02-22 at 21:48 +0100, Miklos Szeredi wrote:
> > This still does not address the situation where a file is 'permanently'
> > mmap'd, does it?
> 
> So?  If application doesn't do msync, then the file times won't be
> updated.  That's allowed by the standard, and so portable applications
> will have to call msync.

It is allowed, but it is clearly not useful behaviour. Nowhere is it set
in stone that we should be implementing just the minimum allowed.

Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
