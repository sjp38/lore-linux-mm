Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EF331900018
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 16:30:33 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fa1so11314262pad.25
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 13:30:33 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.228])
        by mx.google.com with ESMTP id re6si21075520pbc.50.2014.11.11.13.30.31
        for <linux-mm@kvack.org>;
        Tue, 11 Nov 2014 13:30:32 -0800 (PST)
Date: Tue, 11 Nov 2014 16:30:29 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [BUG] mm/page-writeback.c: divide by zero in pos_ratio_polynom
 not fixed
Message-ID: <20141111163029.5d356716@gandalf.local.home>
In-Reply-To: <20141111211615.GE32298@quack.suse.cz>
References: <20141101082325.7be0463f@gandalf.local.home>
	<20141111201539.GA12333@quack.suse.cz>
	<20141111160448.61354836@gandalf.local.home>
	<20141111211615.GE32298@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 11 Nov 2014 22:16:15 +0100
Jan Kara <jack@suse.cz> wrote:


>   BTW, how much memory does the machine have and what is
> /proc/sys/vm/dirty_ratio and /proc/sys/vm/dirty_background_ratio (or
> corresponding dirty_bytes, dirty_background_bytes if you are using them)?
> 
> 								Honza

It's currently booted in my x86_64 kernel (I use this box to test both
32bit and 64bit kernels). Also, note, this box recently went though a
new motherboard upgrade, which added 4 gigs more of memory, bringing it
to a total of 8gigs, which probably explains some things.

I wouldn't normally run such a box with a 32bit kernel.

I'll have to wait a bit before I can boot back to the 32bit kernel to
get the rest of that info for you.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
