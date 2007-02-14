Date: Wed, 14 Feb 2007 10:57:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] mm: NUMA replicated pagecache
In-Reply-To: <20070213060924.GB20644@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0702141052350.975@schroedinger.engr.sgi.com>
References: <20070213060924.GB20644@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Feb 2007, Nick Piggin wrote:

> Just tinkering around with this and got something working, so I'll see
> if anyone else wants to try it.
> 
> Not proposing for inclusion, but I'd be interested in comments or results.

We would be very interested in such a feature. We have another hack that 
shows up to 40% performance improvements.

> At the moment the code is a bit ugly, but it won't take much to make it a
> completely standalone ~400 line module with just a handful of hooks into
> the core mm. So if anyone really wants it, it could be quite realistic to
> get into an includable form.

Would be great but I am a bit skeptical regarding the locking and the 
additonal overhead moving back and forth between replications and non 
replicated page state.

> At some point I did take a look at Dave Hansen's page replication patch for
> ideas, but didn't get far because he was doing a per-inode scheme and I was
> doing per-page. No judgments on which approach is better, but I feel this
> per-page patch is quite neat.

Definitely looks better.

> - Would be nice to transfer master on reclaim. This should be quite easy,
>   must transfer relevant flags, and only if !PagePrivate (which reclaim
>   takes care of).

Transfer master? Meaning you need to remove the replicated pages? Removing 
of replicated pages should transfer reference bit?

> - Should go nicely with lockless pagecache, but haven't merged them yet.

When is that going to happen? Soon I hope?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
