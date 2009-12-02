Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C0D5D6007E3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 16:42:16 -0500 (EST)
From: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Subject: Re: [RFC,PATCH 1/2] dmapool: Don't warn when allowed to retry allocation.
Date: Wed, 2 Dec 2009 23:22:34 +0200
References: <200912021518.35877.roger.oksanen@cs.helsinki.fi> <200912021520.12419.roger.oksanen@cs.helsinki.fi> <alpine.DEB.2.00.0912021355160.2547@router.home>
In-Reply-To: <alpine.DEB.2.00.0912021355160.2547@router.home>
MIME-Version: 1.0
Message-Id: <200912022322.34363.roger.oksanen@cs.helsinki.fi>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Roger Oksanen <roger.oksanen@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wednesday 02 December 2009 21:56:10 Christoph Lameter wrote:
> On Wed, 2 Dec 2009, Roger Oksanen wrote:
> > dmapool: Don't warn when allowed to retry allocation.
> 
> It warns after 10 attempts even when allowed to retry? Description is not
> entirely accurate.

I left one part off by mistake. The whole descriptions should have read
"dmapool uses it's own wait logic, so allocations failing may be retried
if the called specified a waiting GFP_*. Unnecessary warnings only cause
confusion. Every 10th retry will still cause a warning, to disclose a 
possible problem."

10 retries (* POOL_TIMEOUT_JIFFIES) roughly means 1s, so then I assume there 
is really some problems in finding the requested memory. If the pool allocator 
was allowed to fail after n retries, then that point would probably be the 
best place to warn on.

best regards,
-- 
Roger Oksanen <roger.oksanen@cs.helsinki.fi>
http://www.cs.helsinki.fi/u/raoksane
+358 50 355 1990

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
