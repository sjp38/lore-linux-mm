Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
From: Andi Kleen <andi@firstfloor.org>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
	<20080730014308.2a447e71.akpm@linux-foundation.org>
	<20080730172317.GA14138@csn.ul.ie>
	<20080730103407.b110afc2.akpm@linux-foundation.org>
Date: Wed, 06 Aug 2008 20:49:40 +0200
In-Reply-To: <20080730103407.b110afc2.akpm@linux-foundation.org> (Andrew Morton's message of "Wed, 30 Jul 2008 10:34:07 -0700")
Message-ID: <87fxpi567v.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> Do we expect that this change will be replicated in other
> memory-intensive apps?  (I do).

The catch with 2MB pages on x86 is that x86 CPUs generally have
much less 2MB TLB entries than 4K entries. So if you're unlucky
and access a lot of mappings you might actually thrash more with
them. That is why they are not necessarily an universal win.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
