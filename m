Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2D16B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 20:43:18 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <dbb9f012-c09a-438f-99d0-4fbc40428f58@default>
Date: Mon, 30 Aug 2010 17:40:42 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V4 3/8] Cleancache: core ops functions and configuration
References: <20100830223133.GA1272@ca-server1.us.oracle.com
 4C7C3521.7090403@goop.org>
In-Reply-To: <4C7C3521.7090403@goop.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com
List-ID: <linux-mm.kvack.org>

> > +#ifdef CONFIG_CLEANCACHE
> > +#define cleancache_enabled (cleancache_ops.init_fs)
>=20
> Pointers can be used in a boolean context, but it would probably be
> cleaner to have this evaluate to a proper boolean type.  Also I'd
> probably go with an all-caps macro name rather than making it look like
> a variable.

OK, thanks, will fix.
=20
> > +/* useful stats available in /sys/kernel/mm/cleancache */
> > +static unsigned long succ_gets;
> > +static unsigned long failed_gets;
> > +static unsigned long puts;
> > +static unsigned long flushes;
>=20
> I'd probably give these very generic-sounding names some slightly
> unique
> prefix just to help out people looking at "nm" output or using ctags.
>=20
> > +static int get_key(struct inode *inode, struct cleancache_filekey
> *key)
>=20
> Ditto.

OK, will do.

Thanks for the feedback!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
