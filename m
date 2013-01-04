Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 0D0C16B0069
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 19:26:36 -0500 (EST)
Date: Fri, 4 Jan 2013 00:26:35 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130104002635.GA6693@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130102204712.GA17806@dcvr.yhbt.net>
 <1357220469.21409.24574.camel@edumazet-glaptop>
 <20130103183251.GA10113@dcvr.yhbt.net>
 <20130103234558.GA1689@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130103234558.GA1689@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Eric Wong <normalperson@yhbt.net> wrote:
> I think this requires frequent dirtying/cycling of pages to reproduce.
> (from copying large files around) to interact with compaction.
> I'll see if I can reproduce the issue with read-only FS activity.

Still successfully running the read-only test on my main machine, will
provide another update in a few hours or so if it's still successful
(it usually takes <1 hour to hit).

I also fired up a VM on my laptop (still running v3.7) and was able to
get stuck with only 2 cores and 512M on the VM (x86_64).  On the small
VM with little disk space, it doesn't need much dirty data to trigger.
I just did this:

    find $45G_NFS_MOUNT -type f -print0 | \
       xargs -0 -n1 -P4 sh -c 'cat "$1" >> tmp; > tmp' --

...while running two instances of toosleepy (one got stuck and aborted).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
