Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8338E6B01AF
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 11:36:06 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <312cfff6-7ee7-4a6e-a3fd-fc9b6893f0b1@default>
Date: Wed, 2 Jun 2010 08:35:43 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
References: <20100528173510.GA12166@ca-server1.us.oracle.com
 20100602130014.GB7238@shareable.org>
In-Reply-To: <20100602130014.GB7238@shareable.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jamie Lokier <jamie@shareable.org>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

> From: Jamie Lokier [mailto:jamie@shareable.org]
> Subject: Re: [PATCH V2 0/7] Cleancache (was Transcendent Memory):
> overview
>=20
> Dan Magenheimer wrote:
> > Most important, cleancache is "ephemeral".  Pages which are copied
> into
> > cleancache have an indefinite lifetime which is completely unknowable
> > by the kernel and so may or may not still be in cleancache at any
> later time.
> > Thus, as its name implies, cleancache is not suitable for dirty
> pages.  The
> > pseudo-RAM has complete discretion over what pages to preserve and
> what
> > pages to discard and when.
>=20
> Fwiw, the feature sounds useful to userspace too, for those things
> with memory hungry caches like web browsers.  Any plans to make it
> available to userspace?

No plans yet, though we agree it sounds useful, at least for
apps that bypass the page cache (e.g. O_DIRECT).  If you have
time and interest to investigate this further, I'd be happy
to help.  Send email offlist.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
