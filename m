Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 86C8F900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:15:18 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <276f7410-ff4d-4a3b-ab9c-fd1b5fe8c952@default>
Date: Mon, 18 Apr 2011 07:12:46 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] xen: cleancache shim to Xen Transcendent Memory
References: <20110414212002.GA27846@ca-server1.us.oracle.com>
 <1302904935.22658.9.camel@localhost.localdomain>
 <5d23c6c4-5d68-4c2e-af24-2a08f592cb8e@default
 1303116441.5997.107.camel@zakaz.uk.xensource.com>
In-Reply-To: <1303116441.5997.107.camel@zakaz.uk.xensource.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Cc: Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger.kernel@dilger.ca, tytso@mit.edu, mfasheh@suse.com, jlbec@evilplan.org, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, hch@infradead.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, torvalds@linux-foundation.org

> From: Ian Campbell [mailto:Ian.Campbell@eu.citrix.com]
> > >
> > > On Thu, 2011-04-14 at 14:20 -0700, Dan Magenheimer wrote:
> > >
> > > There's no need to build this into a kernel which doesn't have
> > > cleancache (or one of the other frontends), is there? I think there
> > > should be a Kconfig option (even if its not a user visible one)
> with
> > > the appropriate depends/selects.
> >
> > Yes, you're right.  It should eventually depend on
> >
> > CONFIG_CLEANCACHE || CONFIG_FRONTSWAP
> >
> > though there's no sense merging this xen cleancache
> > shim at all unless/until Linus merges cleancache
> > (and hopefully later some evolution of frontswap).
>=20
> Cleancache isn't in already? I thought I saw references to it in
> drivers/staging?

Linus said he would review it after 2.6.39-rc1 was released,
but has neither given thumbs up nor thumbs down so I'm
assuming he didn't have time and it will be reconsidered
for 2.6.40.  This latest patchset (V8) is updated in linux-next.

Yes, zcache is in driver/staging and has references to it.
I guess that proves the chicken comes before the egg...
or was it vice versa? :-)
=20
> > And once cleancache (and/or frontswap) is merged,
> > there's very little reason NOT to enable one or
> > both on a Xen guest kernel.
>=20
> There are software knobs to allow the host- and guest-admin to opt in
> or out as they desire though, right?

Definitely.  Both Xen and a Linux guest have runtime
options, which currently default to off.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
