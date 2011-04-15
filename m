Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD774900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:33:48 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <36009196-0fe9-43f2-8d16-4cc58232195f@default>
Date: Fri, 15 Apr 2011 08:32:21 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V8 4/8] mm/fs: add hooks to support cleancache
References: <20110414211732.GA27761@ca-server1.us.oracle.com>
 <BANLkTimEbtY8F6bpsfhfQ770ao9Hn7Spww@mail.gmail.com>
 <83ef8b69-f041-43e6-a5a9-880ff3da26f2@default
 20110415081054.79a164d3.akpm@linux-foundation.org>
In-Reply-To: <20110415081054.79a164d3.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger.kernel@dilger.ca, tytso@mit.edu, mfasheh@suse.com, jlbec@evilplan.org, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, hch@infradead.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, torvalds@linux-foundation.org

> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> On Fri, 15 Apr 2011 07:47:57 -0700 (PDT) Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
>=20
> > Hi Minchan --
> >
> > > Before I suggested a thing about cleancache_flush_page,
> > > cleancache_flush_inode.
> > >
> > > what's the meaning of flush's semantic?
> > > I thought it means invalidation.
> > > AFAIC, how about change flush with invalidate?
> >
> > I'm not sure the words "flush" and "invalidate" are defined
> > precisely or used consistently everywhere in computer
> > science, but I think that "invalidate" is to destroy
> > a "pointer" to some data, but not necessarily destroy the
> > data itself.   And "flush" means to actually remove
> > the data.  So one would "invalidate a mapping" but one
> > would "flush a cache".
> >
> > Since cleancache_flush_page and cleancache_flush_inode
> > semantically remove data from cleancache, I think flush
> > is a better name than invalidate.
> >
> > Does that make sense?
>=20
> nope ;)
>=20
> Kernel code freely uses "flush" to refer to both invalidation and to
> writeback, sometimes in confusing ways.  In this case,
> cleancache_flush_inode and cleancache_flush_page rather sound like they
> might write those things to backing store.

OK, I guess I am displaying my kernel-newbie-ness... though,
in this case, writeback of a cleancache page to backing store
doesn't make much sense either (since cleancache pages are
by definition "clean").

I'm happy to rename the hooks, though will probably not
repost a V9 unless/until more substantive changes collect...
unless someone considers this an unmergeable offense.

Thanks for the feedback, Minchan and Andrew!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
