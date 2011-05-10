Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 408986B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 21:20:26 -0400 (EDT)
Date: Mon, 9 May 2011 18:26:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap
 chain locking
Message-Id: <20110509182656.5533628e.akpm@linux-foundation.org>
In-Reply-To: <20110510000517.GC6008@one.firstfloor.org>
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org>
	<1304623972-9159-2-git-send-email-andi@firstfloor.org>
	<20110509144324.8e79654a.akpm@linux-foundation.org>
	<4DC86947.30607@linux.intel.com>
	<20110509152841.ec957d23.akpm@linux-foundation.org>
	<20110509230255.GA6008@one.firstfloor.org>
	<20110509161622.57093622.akpm@linux-foundation.org>
	<20110510000517.GC6008@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie

On Tue, 10 May 2011 02:05:17 +0200 Andi Kleen <andi@firstfloor.org> wrote:

> > hm, which atomic ops are those?  We shouldn't need buslocked operations
> > on UP.
> 
> Good point. I forgot they're patched out.
> 
> Then it's likely somewhat slower, but I doubt it's a significant
> slowdown. Essentially it's just a few more if ()s
> 

And presumably some more instruction cachelines here and there.  It'll
be small, but 100*small == large.  We can reduce the overhead to zero,
it's a question of how ugly the end result is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
