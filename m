Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A0A016006B4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 17:18:02 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <fc254547-5926-4cb9-98e1-7a79f7284e30@default>
Date: Fri, 23 Jul 2010 14:17:31 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V3 0/8] Cleancache: overview
References: <20100621231809.GA11111@ca-server1.us.oracle.com4C49468B.40307@vflare.org>
 <840b32ff-a303-468e-9d4e-30fc92f629f8@default
 20100723140440.GA12423@infradead.org
 364c83bd-ccb2-48cc-920d-ffcf9ca7df19@default>
In-Reply-To: <364c83bd-ccb2-48cc-920d-ffcf9ca7df19@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: ngupta@vflare.org, akpm@linux-foundation.org, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@suse.de, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

> > On Fri, Jul 23, 2010 at 06:58:03AM -0700, Dan Magenheimer wrote:
> > > CHRISTOPH AND ANDREW, if you disagree and your concerns have
> > > not been resolved, please speak up.
>=20
> Hi Christoph --
>=20
> Thanks very much for the quick (instantaneous?) reply!
>=20
> > Anything that need modification of a normal non-shared fs is utterly
> > broken and you'll get a clear NAK, so the propsal before is a good
> > one.
>=20
> No, the per-fs opt-in is very sensible; and its design is
> very minimal.

Not to belabor the point, but maybe the right way to think about
this is:

Cleancache is a new optional feature provided by the VFS layer
that potentially dramatically increases page cache effectiveness
for many workloads in many environments at a negligible cost.

Filesystems that are well-behaved and conform to certain restrictions
can utilize cleancache simply by making a call to cleancache_init_fs
at mount time.  Unusual, misbehaving, or poorly layered filesystems
must either add additional hooks and/or undergo extensive additional
testing... or should just not enable the optional cleancache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
