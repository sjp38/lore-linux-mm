Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 923286B0011
	for <linux-mm@kvack.org>; Mon,  9 May 2011 20:05:22 -0400 (EDT)
Date: Tue, 10 May 2011 02:05:17 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap chain locking
Message-ID: <20110510000517.GC6008@one.firstfloor.org>
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org> <1304623972-9159-2-git-send-email-andi@firstfloor.org> <20110509144324.8e79654a.akpm@linux-foundation.org> <4DC86947.30607@linux.intel.com> <20110509152841.ec957d23.akpm@linux-foundation.org> <20110509230255.GA6008@one.firstfloor.org> <20110509161622.57093622.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509161622.57093622.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie

> hm, which atomic ops are those?  We shouldn't need buslocked operations
> on UP.

Good point. I forgot they're patched out.

Then it's likely somewhat slower, but I doubt it's a significant
slowdown. Essentially it's just a few more if ()s

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
