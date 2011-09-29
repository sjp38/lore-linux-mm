Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0CF9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 04:50:44 -0400 (EDT)
Subject: Re: [PATCH 10/18] writeback: dirty position control - bdi reserve
 area
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 29 Sep 2011 10:49:57 +0200
In-Reply-To: <20110929033201.GA21722@localhost>
References: <20110904015305.367445271@intel.com>
	 <20110904020915.942753370@intel.com> <1315318179.14232.3.camel@twins>
	 <20110907123108.GB6862@localhost> <1315822779.26517.23.camel@twins>
	 <20110918141705.GB15366@localhost> <20110918143721.GA17240@localhost>
	 <20110918144751.GA18645@localhost> <20110928140205.GA26617@localhost>
	 <1317221435.24040.39.camel@twins> <20110929033201.GA21722@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317286197.22581.4.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 2011-09-29 at 11:32 +0800, Wu Fengguang wrote:
> > Now I guess the only problem is when nr_bdi * MIN_WRITEBACK_PAGES ~
> > limit, at which point things go pear shaped.
>=20
> Yes. In that case the global @dirty will always be drove up to @limit.
> Once @dirty dropped reasonably below, whichever bdi task wakeup first
> will take the chance to fill the gap, which is not fair for bdi's of
> different speed.
>=20
> Let me retry the thresh=3D1M,10M test cases without MIN_WRITEBACK_PAGES.
> Hopefully the removal of it won't impact performance a lot.=20


Right, so alternatively we could try an argument that this is
sufficiently rare and shouldn't happen. People with lots of disks tend
to also have lots of memory, etc.

If we do find it happens we can always look at it again.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
