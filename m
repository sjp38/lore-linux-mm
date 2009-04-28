Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 27D176B004D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 03:48:06 -0400 (EDT)
Subject: Re: Swappiness vs. mmap() and interactive response
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090428143019.EBBF.A69D9226@jp.fujitsu.com>
References: <20090428044426.GA5035@eskimo.com>
	 <20090428143019.EBBF.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 09:48:39 +0200
Message-Id: <1240904919.7620.73.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-28 at 14:35 +0900, KOSAKI Motohiro wrote:
> (cc to linux-mm and Rik)
> 
> 
> > Hi,
> > 
> > So, I just set up Ubuntu Jaunty (using Linux 2.6.28) on a quad core phenom box,
> > and then I did the following (with XFS over LVM):
> > 
> > mv /500gig/of/data/on/disk/one /disk/two
> > 
> > This quickly caused the system to. grind.. to... a.... complete..... halt.
> > Basically every UI operation, including the mouse in Xorg, started experiencing
> > multiple second lag and delays.  This made the system essentially unusable --
> > for example, just flipping to the window where the "mv" command was running
> > took 10 seconds on more than one occasion.  Basically a "click and get coffee"
> > interface.
> 
> I have some question and request.
> 
> 1. please post your /proc/meminfo
> 2. Do above copy make tons swap-out? IOW your disk read much faster than write?
> 3. cache limitation of memcgroup solve this problem?
> 4. Which disk have your /bin and /usr/bin?
> 

FWIW I fundamentally object to 3 as being a solution.

I still think the idea of read-ahead driven drop-behind is a good one,
alas last time we brought that up people thought differently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
