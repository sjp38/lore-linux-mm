Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3A06B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:48:31 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <57b44b18-0754-445d-af8c-9b3b1da6bd0e@default>
Date: Wed, 2 Jun 2010 19:47:14 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 2/7] Cleancache (was Transcendent Memory): core files
References: <20100528173550.GA12219@ca-server1.us.oracle.com>
 <20100602122900.6c893a6a.akpm@linux-foundation.org>
 <0be9e88e-7b0d-471d-8d49-6dc593dd43be@default 4C06F571.3050306@goop.org>
In-Reply-To: <4C06F571.3050306@goop.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, chris.mason@oracle.com, viro@zeniv.linux.org.uk, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

> > It is intended that there be different flavours but only
> > one can be used in any running kernel.  A driver file/module
> > claims the cleancache_ops pointer (and should check to ensure
> > it is not already claimed).  And if nobody claims cleancache_ops,
> > the hooks should be as non-intrusive as possible.
> >
> > Also note that the operations occur on the order of the number
> > of I/O's, so definitely a lot, but "zillion" may be a bit high. :-)
> >
> > If you think this is a showstoppper, it could be changed
> > to be bound only at compile-time, but then (I think) the claimer
> > could never be a dynamically-loadable module.
>=20
> Andrew is suggesting that rather than making cleancache_ops a pointer
> to
> a structure, just make it a structure, so that calling a function is a
> matter of cleancache_ops.func rather than cleancache_ops->func, thereby
> avoiding a pointer dereference.

OK, I see.  So the claimer of the cleancache_ops structure
just fills in all of the func fields individually?  That
would work too.  IIUC it wouldn't save any instructions
when cleancache_ops is unclaimed because it is still necessary
to check a func pointer against NULL, but would save an extra
pointer indirection and possible cache miss for every use
of any func when it is claimed.

I'll change that for next rev.

Thanks and sorry I misunderstood!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
