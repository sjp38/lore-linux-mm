Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 0E55F6B006E
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 21:35:49 -0500 (EST)
Received: by mail-da0-f51.google.com with SMTP id i30so1835351dad.10
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 18:35:49 -0800 (PST)
Date: Thu, 20 Dec 2012 18:35:50 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ksm: make rmap walks more scalable
In-Reply-To: <20121221003648.GA9649@thinkpad-work.redhat.com>
Message-ID: <alpine.LNX.2.00.1212201830020.28881@eggly.anvils>
References: <alpine.LNX.2.00.1212191735530.25409@eggly.anvils> <alpine.LNX.2.00.1212191742440.25409@eggly.anvils> <50D387FD.4020008@oracle.com> <alpine.LNX.2.00.1212201409170.977@eggly.anvils> <50D3947F.2060503@oracle.com>
 <20121221003648.GA9649@thinkpad-work.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 21 Dec 2012, Petr Holasek wrote:
> On Thu, 20 Dec 2012, Sasha Levin wrote:
> > On 12/20/2012 05:37 PM, Hugh Dickins wrote:
> > > 
> > > To stop these oopses in get_mergeable_page (inlined in
> > > unstable_tree_search_insert) you need the patch I showed on
> > > Tuesday, which I hope he'll merge in for his v6.  That doesn't fix
> > > all of the problems, but hopefully all that you'll encounter before
> > > I've devised a fix for the separate stale stable_nodes issue.
> > 
> > My bad! I thought that this is the finalized version of the patch from
> > Tuesday and was surprised when the oops was still there :)
> > 
> > fwiw I'll use this to report that I'm not seeing any unexpected behaviour
> > with this patch applied.

Thanks, Sasha.

> 
> Hugh, big thanks for your Tuesday fix, I am not able to reproduce reported
> oops any more. I will continue with testing overnight and submit v6 version
> tomorrow if there won't be any problem.

Great, thank you Petr.

> 
> Should I also add [PATCH] ksm: make rmap walks more scalable into v6 or
> can I rely on it?

No, this rmap walks patch is entirely independent of your changes,
and already picked up by Linus into his tree for rc1.

By all means test with it in, or out, but don't fold it into your v6:
Andrew's mmotm posted just now has it already in too.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
