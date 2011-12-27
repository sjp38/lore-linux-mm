Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id F228F6B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 15:30:02 -0500 (EST)
MIME-Version: 1.0
Message-ID: <7866f872-ce94-4516-bd23-936ea3d0b4e3@default>
Date: Tue, 27 Dec 2011 12:29:46 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 1/6] drivers/staging/ramster: cluster/messaging
 foundation
References: <20111222155050.GA21405@ca-server1.us.oracle.com>
 <243729.1325016332@turing-police.cc.vt.edu>
In-Reply-To: <243729.1325016332@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: greg@kroah.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, Kurt Hackel <kurt.hackel@oracle.com>, sjenning@linux.vnet.ibm.com, Chris Mason <chris.mason@oracle.com>

> From: Valdis.Kletnieks@vt.edu [mailto:Valdis.Kletnieks@vt.edu]
> Sent: Tuesday, December 27, 2011 1:06 PM
> To: Dan Magenheimer
> Cc: greg@kroah.com; devel@driverdev.osuosl.org; linux-kernel@vger.kernel.=
org; linux-mm@kvack.org;
> ngupta@vflare.org; Konrad Wilk; Kurt Hackel; sjenning@linux.vnet.ibm.com;=
 Chris Mason
> Subject: Re: [PATCH V2 1/6] drivers/staging/ramster: cluster/messaging fo=
undation
>=20
> On Thu, 22 Dec 2011 07:50:50 PST, Dan Magenheimer said:
>=20
> > Copy cluster subdirectory from ocfs2.  These files implement
> > the basic cluster discovery, mapping, heartbeat / keepalive, and
> > messaging ("o2net") that ramster requires for internode communication.
>=20
> Instead of doing this, can we have the shared files copied to a common
> subdirectory so that ramster and ocfs2 can share them, and we only
> have to fix bugs once?

Hi Valdis --

Thanks for your reply!

Per the discussion at:
https://lkml.org/lkml/2011/12/22/369=20
your suggestion of the common subdirectory will definitely need to happen
before ramster can be promoted out of staging and, at GregKH's request,
I have added a TODO file in V3 to state that.  Before that can happen,
we'll need to work with the ocfs2 maintainers to merge the
necessary ramster-specific changes and implement a separately CONFIG-able
subdirectory for the ocfs2 cluster code.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
