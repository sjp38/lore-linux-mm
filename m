Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EE67B6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 19:14:11 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: Page alloc problems with 2.6.32-rc kernels
Date: Wed, 4 Nov 2009 01:14:07 +0100
References: <20091102122010.GA5552@gibson.comsick.at>
In-Reply-To: <20091102122010.GA5552@gibson.comsick.at>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200911040114.08879.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Michael Guntsche <mike@it-loops.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Adding a few more CCs.

On Monday 02 November 2009, Michael Guntsche wrote:
> > I have the server running with all with patches applied and it runs
> > without any issues. Since adding patch5 seems to make a difference I
> > will revert 1-4 and only apply patch 5 to see if it work too. I will
> > report back as soon as I have news.
>
> Current status of my tests here. With only patch 5 applied (the revert)
> I am not able to reproduce the problem. Reading through the ml archives
> I noticed that this revert is somewhat controversial since it seems to
> fix other bugs. Is it possible that reverting those fixes just hide the
> bug I am seeing instead of fixing it?

Thanks Michael. That means we now have two cases where reverting the 
congestion_wait() changes from .31-rc3 (8aa7e847d8 + 373c0a7ed3) makes a 
clear and significant difference.

I wonder if more effort could/should be made on this aspect.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
