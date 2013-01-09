Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D73A76B005D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 21:14:10 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id rl6so707249pac.1
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 18:14:10 -0800 (PST)
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20130108232325.GA5948@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
	 <20130102200848.GA4500@dcvr.yhbt.net> <20130104160148.GB3885@suse.de>
	 <20130106120700.GA24671@dcvr.yhbt.net> <20130107122516.GC3885@suse.de>
	 <20130107223850.GA21311@dcvr.yhbt.net> <20130108224313.GA13304@suse.de>
	 <20130108232325.GA5948@dcvr.yhbt.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Jan 2013 18:14:07 -0800
Message-ID: <1357697647.18156.1217.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 2013-01-08 at 23:23 +0000, Eric Wong wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> > Please try the following patch. However, even if it works the benefit of
> > capture may be so marginal that partially reverting it and simplifying
> > compaction.c is the better decision.
> 
> I already got my VM stuck on this one.  I had two twosleepy instances,
> 2774 was the one that got stuck (also confirmed by watching top).
> 
> Btw, have you been able to reproduce this on your end?
> 
> I think the easiest reproduction on my 2-core VM is by running 2
> twosleepy processes and doing the following to dirty a lot of pages:

Given the persistent sk_stream_wait_memory() traces I suspect a plain
TCP bug, triggered by some extra wait somewhere.

Please mm guys don't spend too much time right now, I'll try to
reproduce the problem.

Don't be confused by sk_stream_wait_memory() name.
A thread is stuck here because TCP stack is failing to wake it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
