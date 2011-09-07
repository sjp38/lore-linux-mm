Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD3D6B0173
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 06:36:35 -0400 (EDT)
Subject: Re: [PATCH 05/18] writeback: per task dirty rate limit
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 07 Sep 2011 09:31:56 +0200
In-Reply-To: <20110907010448.GA6513@localhost>
References: <20110904015305.367445271@intel.com>
	 <20110904020915.240747479@intel.com> <1315324030.14232.14.camel@twins>
	 <20110907010448.GA6513@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315380716.11101.5.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-09-07 at 09:04 +0800, Wu Fengguang wrote:

> So the sqrt naturally leads to less overheads and more N tolerance for
> large memory servers, which have large (thresh-freerun) gaps.

Thanks, and as you say its an initial guess, later refined using patch
14.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
