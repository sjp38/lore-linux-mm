Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 796F0900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 04:47:26 -0400 (EDT)
Subject: RE: [PATCH] xen: cleancache shim to Xen Transcendent Memory
From: Ian Campbell <Ian.Campbell@eu.citrix.com>
In-Reply-To: <5d23c6c4-5d68-4c2e-af24-2a08f592cb8e@default>
References: <20110414212002.GA27846@ca-server1.us.oracle.com 1302904935.22658.9.camel@localhost.localdomain>
	 <5d23c6c4-5d68-4c2e-af24-2a08f592cb8e@default>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 18 Apr 2011 09:47:21 +0100
Message-ID: <1303116441.5997.107.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Chris Mason <chris.mason@oracle.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "tytso@mit.edu" <tytso@mit.edu>, "mfasheh@suse.com" <mfasheh@suse.com>, "jlbec@evilplan.org" <jlbec@evilplan.org>, "matthew@wil.cx" <matthew@wil.cx>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "ocfs2-devel@oss.oracle.com" <ocfs2-devel@oss.oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hch@infradead.org" <hch@infradead.org>, "ngupta@vflare.org" <ngupta@vflare.org>, "jeremy@goop.org" <jeremy@goop.org>, "JBeulich@novell.com" <JBeulich@novell.com>, Kurt Hackel <kurt.hackel@oracle.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, Dave Mccracken <dave.mccracken@oracle.com>, "riel@redhat.com" <riel@redhat.com>, "avi@redhat.com" <avi@redhat.com>, Konrad Wilk <konrad.wilk@oracle.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "yinghan@google.com" <yinghan@google.com>, "gthelen@google.com" <gthelen@google.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On Fri, 2011-04-15 at 23:53 +0100, Dan Magenheimer wrote:
> > From: Ian Campbell [mailto:Ian.Campbell@citrix.com]
> > Sent: Friday, April 15, 2011 4:02 PM
> > Subject: Re: [PATCH] xen: cleancache shim to Xen Transcendent Memory
> > 
> > On Thu, 2011-04-14 at 14:20 -0700, Dan Magenheimer wrote:
> > > [PATCH] xen: cleancache shim to Xen Transcendent Memory
> > >
> > > This patch provides a shim between the kernel-internal cleancache
> > > API (see Documentation/mm/cleancache.txt) and the Xen Transcendent
> > > Memory ABI (see http://oss.oracle.com/projects/tmem).
> > 
> > There's no need to build this into a kernel which doesn't have
> > cleancache (or one of the other frontends), is there? I think there
> > should be a Kconfig option (even if its not a user visible one) with
> > the appropriate depends/selects.
> 
> Yes, you're right.  It should eventually depend on
> 
> CONFIG_CLEANCACHE || CONFIG_FRONTSWAP
> 
> though there's no sense merging this xen cleancache
> shim at all unless/until Linus merges cleancache
> (and hopefully later some evolution of frontswap).

Cleancache isn't in already? I thought I saw references to it in
drivers/staging?

> And once cleancache (and/or frontswap) is merged,
> there's very little reason NOT to enable one or
> both on a Xen guest kernel.

There are software knobs to allow the host- and guest-admin to opt in or
out as they desire though, right?

Ian.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
