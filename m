Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADF0900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:50:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <83ef8b69-f041-43e6-a5a9-880ff3da26f2@default>
Date: Fri, 15 Apr 2011 07:47:57 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V8 4/8] mm/fs: add hooks to support cleancache
References: <20110414211732.GA27761@ca-server1.us.oracle.com
 BANLkTimEbtY8F6bpsfhfQ770ao9Hn7Spww@mail.gmail.com>
In-Reply-To: <BANLkTimEbtY8F6bpsfhfQ770ao9Hn7Spww@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger.kernel@dilger.ca, tytso@mit.edu, mfasheh@suse.com, jlbec@evilplan.org, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, hch@infradead.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, torvalds@linux-foundation.org

Hi Minchan --

> First of all, thanks for resolving conflict with my patch.

You're welcome!  As I pointed out offlist, yours was the first
change in MM that caused any semantic changes to the cleancache
core hooks patch since before 2.6.18.
=20
> Before I suggested a thing about cleancache_flush_page,
> cleancache_flush_inode.
>=20
> what's the meaning of flush's semantic?
> I thought it means invalidation.
> AFAIC, how about change flush with invalidate?

I'm not sure the words "flush" and "invalidate" are defined
precisely or used consistently everywhere in computer
science, but I think that "invalidate" is to destroy
a "pointer" to some data, but not necessarily destroy the
data itself.   And "flush" means to actually remove
the data.  So one would "invalidate a mapping" but one
would "flush a cache".

Since cleancache_flush_page and cleancache_flush_inode
semantically remove data from cleancache, I think flush
is a better name than invalidate.

Does that make sense?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
