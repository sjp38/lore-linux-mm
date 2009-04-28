Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CD22E6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 04:24:38 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S8P0hF004126
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Apr 2009 17:25:00 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DA25745DE51
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:24:59 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BA72B45DE4E
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:24:59 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A1EBA1DB803C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:24:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 62B441DB803F
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:24:59 +0900 (JST)
Date: Tue, 28 Apr 2009 17:23:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Swappiness vs. mmap() and interactive response
Message-Id: <20090428172327.6d3413ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1240906292.7620.79.camel@twins>
References: <20090428044426.GA5035@eskimo.com>
	<20090428143019.EBBF.A69D9226@jp.fujitsu.com>
	<1240904919.7620.73.camel@twins>
	<661de9470904280058ub16c66bi6a52d36ca4c2d52c@mail.gmail.com>
	<1240906292.7620.79.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Apr 2009 10:11:32 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, 2009-04-28 at 13:28 +0530, Balbir Singh wrote:
> > On Tue, Apr 28, 2009 at 1:18 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > > On Tue, 2009-04-28 at 14:35 +0900, KOSAKI Motohiro wrote:
> > >> (cc to linux-mm and Rik)
> > >>
> > >>
> > >> > Hi,
> > >> >
> > >> > So, I just set up Ubuntu Jaunty (using Linux 2.6.28) on a quad core phenom box,
> > >> > and then I did the following (with XFS over LVM):
> > >> >
> > >> > mv /500gig/of/data/on/disk/one /disk/two
> > >> >
> > >> > This quickly caused the system to. grind.. to... a.... complete..... halt.
> > >> > Basically every UI operation, including the mouse in Xorg, started experiencing
> > >> > multiple second lag and delays.  This made the system essentially unusable --
> > >> > for example, just flipping to the window where the "mv" command was running
> > >> > took 10 seconds on more than one occasion.  Basically a "click and get coffee"
> > >> > interface.
> > >>
> > >> I have some question and request.
> > >>
> > >> 1. please post your /proc/meminfo
> > >> 2. Do above copy make tons swap-out? IOW your disk read much faster than write?
> > >> 3. cache limitation of memcgroup solve this problem?
> > >> 4. Which disk have your /bin and /usr/bin?
> > >>
> > >
> > > FWIW I fundamentally object to 3 as being a solution.
> > >
> > 
> > memcgroup were not created to solve latency problems, but they do
> > isolate memory and if that helps latency, I don't see why that is a
> > problem. I don't think isolating applications that we think are not
> > important and interfere or consume more resources than desired is a
> > bad solution.
> 
> So being able to isolate is a good excuse for poor replacement these
> days?
> 
While the kernel can't catch what's going on and what's wanted.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
