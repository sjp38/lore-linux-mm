Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 792096B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 20:59:18 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <91408f0c-0135-427f-b148-446f54b232eb@default>
Date: Mon, 30 Aug 2010 17:57:04 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V4 5/8] Cleancache: ext3 hook for cleancache
References: <20100830223233.GA1317@ca-server1.us.oracle.com
 4C7C3666.2080601@goop.org>
In-Reply-To: <4C7C3666.2080601@goop.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com
List-ID: <linux-mm.kvack.org>

> > @@ -1349,6 +1350,7 @@ static int ext3_setup_super(struct super
> >  =09} else {
> >  =09=09ext3_msg(sb, KERN_INFO, "using internal journal");
> >  =09}
> > +=09sb->cleancache_poolid =3D cleancache_init_fs(PAGE_SIZE);
>=20
> Do you really need to pass in the page size?  What about just
> "cleancache_init_fs(sb)" rather than exposing the
> "sb->cleancache_poolid"?  In other words, what if you want to do
> more/other per-filesystem init at some point?

IIRC, I think I was trying to stay away from including
fs.h in cleancache.h (or one of its predecessors).  I
agree that that no longer makes sense and it is cleaner
as you suggest.  Will change.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
