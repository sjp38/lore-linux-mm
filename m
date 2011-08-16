Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 570076B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 08:10:14 -0400 (EDT)
Date: Tue, 16 Aug 2011 20:10:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/2 v2] writeback: Add writeback stats for pages written
Message-ID: <20110816121007.GA13391@localhost>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
 <1313189245-7197-2-git-send-email-curtw@google.com>
 <20110815134846.GB13534@localhost>
 <CAO81RMYmxRiGpEjLGyjKNeNxXg8UJDuVosNdHGKt70gezTjxGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAO81RMYmxRiGpEjLGyjKNeNxXg8UJDuVosNdHGKt70gezTjxGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Curt,

> > Another question is, how can the display format be script friendly?
> > The current form looks not easily parse-able at least for "cut"..
> 
> I suppose you mean because of the variable number of tokens.  Yeah,
> this can be hard.  Of course, I always just use "awk '{print $NF}'"
> and it works for me :-) .  But I'd be happy to change these to use a
> consistent # of args.

Yes, thank you.  One possible format come to my mind later is to
present the numbers in a 2d table, like this:

                        pages           chunks          works          chunk_kb    work_kbps
balance_dirty_pages     XXXXX             XXXX            XXX              XXXX        XXXXX
background              XXXXX             XXXX            XXX              XXXX        XXXXX
sync                    XXXXX             XXXX            XXX              XXXX        XXXXX
...

The format is not only human friendly and trivial for scripting, but
also permits to add new lines or columns (append only though) without
breaking compatibility.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
