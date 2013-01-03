Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 5CDD86B005D
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 18:45:59 -0500 (EST)
Date: Thu, 3 Jan 2013 23:45:58 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130103234558.GA1689@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130102204712.GA17806@dcvr.yhbt.net>
 <1357220469.21409.24574.camel@edumazet-glaptop>
 <20130103183251.GA10113@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130103183251.GA10113@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Eric Wong <normalperson@yhbt.net> wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > With the following patch, I cant reproduce the 'apparent stuck'
> 
> Right, the output is just an approximation and the logic there
> was bogus.
> 
> Thanks for looking at this.

I'm still able to reproduce the issue under v3.8-rc2 with your patch
for toosleepy.

(As expected when blocked,) TCP send() will eventually return
ETIMEOUT when I forget to check (and toosleepy will abort from it)

I think this requires frequent dirtying/cycling of pages to reproduce.
(from copying large files around) to interact with compaction.
I'll see if I can reproduce the issue with read-only FS activity.

With 3.7.1 and compaction/THP disabled, I was able to run ~21 hours
and copy a few TB around without anything getting stuck.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
