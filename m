Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2BDBE6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 04:11:28 -0400 (EDT)
Subject: Re: Swappiness vs. mmap() and interactive response
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <661de9470904280058ub16c66bi6a52d36ca4c2d52c@mail.gmail.com>
References: <20090428044426.GA5035@eskimo.com>
	 <20090428143019.EBBF.A69D9226@jp.fujitsu.com>
	 <1240904919.7620.73.camel@twins>
	 <661de9470904280058ub16c66bi6a52d36ca4c2d52c@mail.gmail.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 10:11:32 +0200
Message-Id: <1240906292.7620.79.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-28 at 13:28 +0530, Balbir Singh wrote:
> On Tue, Apr 28, 2009 at 1:18 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Tue, 2009-04-28 at 14:35 +0900, KOSAKI Motohiro wrote:
> >> (cc to linux-mm and Rik)
> >>
> >>
> >> > Hi,
> >> >
> >> > So, I just set up Ubuntu Jaunty (using Linux 2.6.28) on a quad core phenom box,
> >> > and then I did the following (with XFS over LVM):
> >> >
> >> > mv /500gig/of/data/on/disk/one /disk/two
> >> >
> >> > This quickly caused the system to. grind.. to... a.... complete..... halt.
> >> > Basically every UI operation, including the mouse in Xorg, started experiencing
> >> > multiple second lag and delays.  This made the system essentially unusable --
> >> > for example, just flipping to the window where the "mv" command was running
> >> > took 10 seconds on more than one occasion.  Basically a "click and get coffee"
> >> > interface.
> >>
> >> I have some question and request.
> >>
> >> 1. please post your /proc/meminfo
> >> 2. Do above copy make tons swap-out? IOW your disk read much faster than write?
> >> 3. cache limitation of memcgroup solve this problem?
> >> 4. Which disk have your /bin and /usr/bin?
> >>
> >
> > FWIW I fundamentally object to 3 as being a solution.
> >
> 
> memcgroup were not created to solve latency problems, but they do
> isolate memory and if that helps latency, I don't see why that is a
> problem. I don't think isolating applications that we think are not
> important and interfere or consume more resources than desired is a
> bad solution.

So being able to isolate is a good excuse for poor replacement these
days?

Also, exactly because its isolated/limited its sub-optimal.


> > I still think the idea of read-ahead driven drop-behind is a good one,
> > alas last time we brought that up people thought differently.
> 
> I vaguely remember the patches, but can't recollect the details.

A quick google gave me this:

  http://lkml.org/lkml/2007/7/21/219


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
