Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 8BB486B004D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 17:06:40 -0500 (EST)
MIME-Version: 1.0
Message-ID: <1f76c37d-15d4-4c62-8c64-8293d3382b4a@default>
Date: Thu, 22 Dec 2011 14:06:26 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 1/6] drivers/staging/ramster: cluster/messaging
 foundation
References: <20111222155050.GA21405@ca-server1.us.oracle.com>
 <20111222173129.GB28856@kroah.com>
In-Reply-To: <20111222173129.GB28856@kroah.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, Kurt Hackel <kurt.hackel@oracle.com>, sjenning@linux.vnet.ibm.com, Chris Mason <chris.mason@oracle.com>

> From: Greg KH [mailto:greg@kroah.com]

Thanks for the quick response!

> Sent: Thursday, December 22, 2011 10:31 AM
> To: Dan Magenheimer
> Cc: devel@driverdev.osuosl.org; linux-kernel@vger.kernel.org; linux-mm@kv=
ack.org; ngupta@vflare.org;
> Konrad Wilk; Kurt Hackel; sjenning@linux.vnet.ibm.com; Chris Mason
> Subject: Re: [PATCH V2 1/6] drivers/staging/ramster: cluster/messaging fo=
undation
>=20
> On Thu, Dec 22, 2011 at 07:50:50AM -0800, Dan Magenheimer wrote:
> > >From 93c00028709a5d423de77a2fc24d32ec10eca443 Mon Sep 17 00:00:00 2001
> > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Date: Wed, 21 Dec 2011 14:01:54 -0700
> > Subject: [PATCH V2 1/6] drivers/staging/ramster: cluster/messaging foun=
dation
>=20
> Why duplicate this in the email body?  That forces me to edit the
> patches and remove them, please use git send-email...

OK, sorry, will do.  Still learning the git tools and my mutt
scripts use that line to create the subject line.  I'll try
git-send-email next time.
=20
> > Copy cluster subdirectory from ocfs2.  These files implement
> > the basic cluster discovery, mapping, heartbeat / keepalive, and
> > messaging ("o2net") that ramster requires for internode communication.
> > Note: there are NO ramster-specific changes yet; this commit
> > does NOT pass checkpatch since the copied source files do not.
>=20
> Why are you copying the files, and not just exporting the symbols you
> need/want to use here?  Are you going to be able to properly track
> keeping this code in sync?

This particular part of ocfs2 has never been broken out for non-ocfs2
use before, some changes to the ocfs2 core cluster code is necessary
for ramster to use that code (see patch 3), and ramster is currently
incompatible with real ocfs2 anyway (requires !CONFIG_OCFS2_FS).  I will
definitely work with Joel Becker to see if these code interdependencies
can be merged before ramster could possibly be promoted out of staging but,
for now for staging, this seemed to be an expedient way to make
use of the ocfs2 core cluster code but still incorporate some required
ramster changes.  This way, also, I think it is not necessary to keep the
code in sync every release, but still allow for easy merging later.

> Same goes for your other patch in this series that copies code, why do
> that?

The other code copies are from drivers/staging/zcache.  The tmem.c/h
changes can definitely be shared between zcache and ramster (and
I've said before that the eventual destination tmem.c/h is the linux
lib directory).  The zcache.c changes are most likely mergeable but
I know that Seth Jennings and Nitin Gupta are working on some
other significant changes (including a new allocator which would
replace the lengthy zbud code and breaking zcache.c into many smaller
files), so thought it best to branch temporarily and merge later.

> Are there goals to eventually not have duplicated code?  If so,
> what are they, and why not mention them?

Sorry, you're right, I should have included the above paragraphs
in the commit comments.

If you disagree with any of this, please let me know.

Thanks and happy holidays!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
