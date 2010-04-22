Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7486E6B01F2
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 11:49:00 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
Date: Thu, 22 Apr 2010 08:48:31 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com
 4BD06B31.9050306@redhat.com>
In-Reply-To: <4BD06B31.9050306@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > a synchronous concurrency-safe page-oriented pseudo-RAM device (such
> >  :
> > conform to certain policies as follows:
>=20
> How baked in is the synchronous requirement?  Memory, for example, can
> be asynchronous if it is copied by a dma engine, and since there are
> hardware encryption engines, there may be hardware compression engines
> in the future.

Thanks for the comment!

Synchronous is required, but likely could be simulated by ensuring all
coherency (and concurrency) requirements are met by some intermediate
"buffering driver" -- at the cost of an extra page copy into a buffer
and overhead of tracking the handles (poolid/inode/index) of pages in
the buffer that are "in flight".  This is an approach we are considering
to implement an SSD backend, but hasn't been tested yet so, ahem, the
proof will be in the put'ing. ;-)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
