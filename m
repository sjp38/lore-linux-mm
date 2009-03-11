Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D88A86B004D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 14:53:47 -0400 (EDT)
Date: Wed, 11 Mar 2009 19:53:39 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311185339.GL27823@random.random>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311174103.GA11979@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Wed, Mar 11, 2009 at 06:41:03PM +0100, Ingo Molnar wrote:
> Hm, is there any security impact? Andrea is talking about data 
> corruption. I'm wondering whether that's just corruption 
> relative to whatever twisted semantics O_DIRECT has in this case 
> [which would be harmless], or some true pagecache corruption 

I don't think it's exploitable and I don't see this much as a security
issue. This can only corrupt user data inside anonymous pages (not
filesystem metadata or kernel pagecache). Side effects will be the
usual ones of random user memory corruption or as worse it can lead to
I/O corruption on disk, but only in user data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
