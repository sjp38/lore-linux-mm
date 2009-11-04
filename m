Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCA16B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 18:07:32 -0500 (EST)
Date: Thu, 5 Nov 2009 00:07:19 +0100
From: Michael Guntsche <mike@it-loops.com>
Subject: Re: Page alloc problems with 2.6.32-rc kernels
Message-ID: <20091104230719.GA17756@gibson.comsick.at>
References: <20091102122010.GA5552@gibson.comsick.at>
 <200911040114.08879.elendil@planet.nl>
 <20091104071750.GA19287@gibson.comsick.at>
 <200911042314.35006.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200911042314.35006.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04 Nov 09 23:14, Frans Pop wrote:
> OK. Can you tell us a bit more about your setup:
> - how much RAM does the system have?
512MB 
> - what's so special about mutt in your case that it triggers these errors?
>   - do you maybe have a huge mailbox, so mutt uses a lot of memory?
>   - does starting/use mutt cause swapping when you see the errors?
Mutt is accessing a maildir directory with a several subdirectories
directly. All of them are added as mailboxes so I can jump to unread
mails. During startup and folder changing mutt is accessing all the
mailboxes.
> 
> From your first mail it does look as if you had little free memory and that 
> swap was in use.
I noticed that as well.
During the last days memory usage was not that high so maybe this
is the reason why I did not see any errors. I will continue running 
latest git and see if a get the errors again when more memory is being
used.

Kind regards,
Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
