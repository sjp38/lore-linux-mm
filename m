Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E6B596B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 16:17:55 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b1036777-129b-4531-a730-1e9e5a87cea9@default>
Date: Thu, 22 Apr 2010 13:15:50 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com>
 <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default
 4BD07594.9080905@redhat.com>
In-Reply-To: <4BD07594.9080905@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > Synchronous is required, but likely could be simulated by ensuring
> all
> > coherency (and concurrency) requirements are met by some intermediate
> > "buffering driver" -- at the cost of an extra page copy into a buffer
> > and overhead of tracking the handles (poolid/inode/index) of pages in
> > the buffer that are "in flight".  This is an approach we are
> considering
> > to implement an SSD backend, but hasn't been tested yet so, ahem, the
> > proof will be in the put'ing. ;-)
>=20
> Much easier to simulate an asynchronous API with a synchronous backend.

Indeed.  But an asynchronous API is not appropriate for frontswap
(or cleancache).  The reason the hooks are so simple is because they
are assumed to be synchronous so that the page can be immediately
freed/reused.
=20
> Well, copying memory so you can use a zero-copy dma engine is
> counterproductive.

Yes, but for something like an SSD where copying can be used to
build up a full 64K write, the cost of copying memory may not be
counterproductive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
