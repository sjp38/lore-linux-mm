Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DA7D36B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 08:26:59 -0400 (EDT)
Date: Tue, 16 Aug 2011 20:26:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/2 v2] writeback: Add writeback stats for pages written
Message-ID: <20110816122654.GB13391@localhost>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
 <1313189245-7197-2-git-send-email-curtw@google.com>
 <20110815150348.GC6597@quack.suse.cz>
 <CAO81RMbe=ht0H_Ut9ybATKZFV7KFDBP8oT1_ZHz-Ve87gcvq2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAO81RMbe=ht0H_Ut9ybATKZFV7KFDBP8oT1_ZHz-Ve87gcvq2A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Curt,

> > A The above stats are probably useful. I'm not so convinced about the stats
> > below - it looks like it should be simple enough to get them by enabling
> > some trace points and processing output (or if we are missing some
> > tracepoints, it would be worthwhile to add them).
> 
> For these specifically, I'd agree with you.  In general, though, I
> think that having generally available aggregated stats is really
> useful, in a different way than tracepoints are.

If there comes such useful aggregated stats in future, they may go to
vmstat and/or /debug/bdi/<dev>/stats.

Then we make the writeback stats a simple uniform interface rather
than a hybrid one.

> >
> >> A  A periodic writeback A  A  A  A  A  A  A  A  A  A  A 377

The above one can go to the "work" column, "periodic" row of the
writeback stats table :)

I'm in particular interested in the "work" column of the
"try_to_free_pages" row. I also suspect there could be many
short-lived background work, hence there lots of them.

> >> A  A single inode wait A  A  A  A  A  A  A  A  A  A  A  A  0
> >> A  A writeback_wb wait A  A  A  A  A  A  A  A  A  A  A  A  1

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
