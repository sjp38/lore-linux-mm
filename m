Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id B7E5F6B005D
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 22:52:55 -0500 (EST)
Date: Fri, 4 Jan 2013 03:52:54 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130104035254.GA17408@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130102204712.GA17806@dcvr.yhbt.net>
 <1357220469.21409.24574.camel@edumazet-glaptop>
 <20130103183251.GA10113@dcvr.yhbt.net>
 <20130103234558.GA1689@dcvr.yhbt.net>
 <20130104002635.GA6693@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130104002635.GA6693@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Eric Wong <normalperson@yhbt.net> wrote:
> Eric Wong <normalperson@yhbt.net> wrote:
> > I think this requires frequent dirtying/cycling of pages to reproduce.
> > (from copying large files around) to interact with compaction.
> > I'll see if I can reproduce the issue with read-only FS activity.
> 
> Still successfully running the read-only test on my main machine, will
> provide another update in a few hours or so if it's still successful
> (it usually takes <1 hour to hit).

The read-only test is still going on my main machine.
I think writes/dirty data is required to reproduce the issue...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
