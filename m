Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2687A6B016A
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 13:10:59 -0400 (EDT)
Subject: Re: [PATCH 3/5] writeback: dirty rate control
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 10 Aug 2011 19:10:26 +0200
In-Reply-To: <20110810140002.GA29724@localhost>
References: <20110806084447.388624428@intel.com>
	 <20110806094526.878435971@intel.com> <20110809155046.GD6482@redhat.com>
	 <1312906591.1083.43.camel@twins> <20110810140002.GA29724@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312996226.23660.43.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-08-10 at 22:00 +0800, Wu Fengguang wrote:
>=20
> > Although I'm not quite sure how he keeps fairness in light of the
> > sleep time bounding to MAX_PAUSE.
>=20
> Firstly, MAX_PAUSE will only be applied when the dirty pages rush
> high (dirty exceeded).  Secondly, the dirty exceeded state is global
> to all tasks, in which case each task will sleep for MAX_PAUSE equally.
> So the fairness is still maintained in dirty exceeded state.=20

Its not immediately apparent how dirty_exceeded and MAX_PAUSE interact,
but having everybody sleep MAX_PAUSE doesn't necessarily mean its fair,
its only fair if they dirty at the same rate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
