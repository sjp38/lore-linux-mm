Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 602A16B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 02:18:05 -0500 (EST)
Date: Wed, 4 Nov 2009 08:17:50 +0100
From: Michael Guntsche <mike@it-loops.com>
Subject: Re: Page alloc problems with 2.6.32-rc kernels
Message-ID: <20091104071750.GA19287@gibson.comsick.at>
References: <20091102122010.GA5552@gibson.comsick.at>
 <200911040114.08879.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200911040114.08879.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04 Nov 09 01:14, Frans Pop wrote:
> Thanks Michael. That means we now have two cases where reverting the 
> congestion_wait() changes from .31-rc3 (8aa7e847d8 + 373c0a7ed3) makes a 
> clear and significant difference.
> 
> I wonder if more effort could/should be made on this aspect.

Good morning Frans,

As a cross check I reverted the revert here and tried to reproduce the
problem again. It is a lot harder to trigger for me now (I was not able
to reproduce it yet). I did update my local git tree though, can you
reproduce this problem on your side with current git?

Kind regards,
Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
