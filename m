Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3439E6B01EE
	for <linux-mm@kvack.org>; Fri, 14 May 2010 16:36:11 -0400 (EDT)
Subject: Re: Defrag in shrinkers
From: Andi Kleen <andi@firstfloor.org>
References: <1273821863-29524-1-git-send-email-david@fromorbit.com>
	<alpine.DEB.2.00.1005141244380.9466@router.home>
Date: Fri, 14 May 2010 22:36:03 +0200
In-Reply-To: <alpine.DEB.2.00.1005141244380.9466@router.home> (Christoph Lameter's message of "Fri\, 14 May 2010 12\:46\:52 -0500 \(CDT\)")
Message-ID: <87y6fmmdak.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux.com> writes:

> Would it also be possible to add some defragmentation logic when you
> revise the shrinkers? Here is a prototype patch that would allow you to
> determine the other objects sitting in the same page as a given object.
>
> With that I hope that you have enough information to determine if its
> worth to evict the other objects as well to reclaim the slab page.

I like the idea, it would be useful for the hwpoison code too,
when it tries to clean a page.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
