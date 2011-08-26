Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E28FB6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 06:42:49 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 26 Aug 2011 12:42:22 +0200
In-Reply-To: <20110826100428.GA7996@localhost>
References: <20110812142020.GB17781@localhost>
	 <1314027488.24275.74.camel@twins> <20110823034042.GC7332@localhost>
	 <1314093660.8002.24.camel@twins> <20110823141504.GA15949@localhost>
	 <20110823174757.GC15820@redhat.com> <20110824001257.GA6349@localhost>
	 <1314202378.6925.48.camel@twins> <20110826001846.GA6118@localhost>
	 <1314349469.26922.24.camel@twins> <20110826100428.GA7996@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314355342.9377.5.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-08-26 at 18:04 +0800, Wu Fengguang wrote:
> Sorry I'm now feeling lost...

hehe welcome to my world ;-)

Seriously though, I appreciate all the effort you put in trying to
explain things. I feel I do understand things now, although I might not
completely agree with them quite yet ;-)

I'll go read the v9 patch-set you send out and look at some of the
details (such as pos_ratio being comprised of both global and bdi
limits, which so far has been somewhat glossed over).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
