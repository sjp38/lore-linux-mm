Date: Wed, 21 Apr 2004 03:10:10 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: msync() behaviour broken for MS_ASYNC, revert patch?
Message-ID: <20040421021010.GC23621@mail.shareable.org>
References: <1080771361.1991.73.camel@sisko.scot.redhat.com> <20040416223548.GA27540@mail.shareable.org> <1082411657.2237.128.camel@sisko.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1082411657.2237.128.camel@sisko.scot.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ulrich Drepper <drepper@redhat.com>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > If so, what was the change?
> 
> 2.4.9 behaved like current 2.6 --- on MS_ASYNC, it did a
> set_page_dirty() which means the page will get picked up by the next
> 5-second bdflush pass.  But later 2.4 kernels were changed so that they
> started MS_ASYNC IO immediately with filemap_fdatasync() (which is
> asynchronous regarding the new IO, but which blocks synchronously if
> there is already old IO in flight on the page.)
> 
> That was reverted back to the earlier, 2.4.9 behaviour in the 2.5
> series.

It was 2.5.68.

Thanks, that's very helpful.

msync(0) has always had behaviour consistent with the <=2.4.9 and
>=2.5.68 MS_ASYNC behaviour, is that right?

If so, programs may as well "#define MS_ASYNC 0" on Linux, to get well
defined and consistent behaviour.  It would be nice to change the
definition in libc to zero, but I don't think it's possible because
msync(MS_SYNC|MS_ASYNC) needs to fail.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
