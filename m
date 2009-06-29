Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB396B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 17:14:00 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6639b922-4ed7-48fd-9a3d-c78a4f93355c@default>
Date: Mon, 29 Jun 2009 14:13:56 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] transcendent memory for Linux
In-Reply-To: <20090629203619.GA6611@elf.ucw.cz>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>

> > It is documented currently at:
> >=20
> > http://oss.oracle.com/projects/tmem/documentation/api/
> >=20
> > (just noticed I still haven't posted version 0.0.2 which
> > has a few minor changes).
> >=20
> > I will add a briefer description of this API in Documentation/
>=20
> Please do.

OK, will do.

> At least TMEM_NEW_POOL() looks quite ugly. Why uuid? Mixing flags into
> size argument is strange.

The uuid is only used for shared pools.  If two different
"tmem clients" (guests) agree on a 128-bit "shared secret",
they can share a tmem pool.  For ocfs2, the 128-bit uuid in
the on-disk superblock is used for this purpose to implement
shared precache.  (Pages evicted by one cluster node
can be used by another cluster node that co-resides on
the same physical system.)

The (page)size argument is always fixed (at PAGE_SIZE) for
any given kernel.  The underlying implementation can
be capable of supporting multiple pagesizes.

So for the basic precache and preswap uses, "new pool"
has a very simple interface.

> > It is in-kernel only because some of the operations have
> > a parameter that is a physical page frame number.
>=20
> In-kernel API is probably better described as function prototypes.

Good idea.  I will do that.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
