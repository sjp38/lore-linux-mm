Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA62EA0g030925
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 11:14:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B821345DD87
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:14:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC19845DD7F
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:14:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ED051DB8038
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:14:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 427431DB803A
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 11:14:08 +0900 (JST)
Date: Thu, 6 Nov 2008 11:13:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
 hotplug
Message-Id: <20081106111332.8d24a11f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1225936986.6216.23.camel@nigel-laptop>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	<1225817945.12673.602.camel@nimitz>
	<20081105093837.e073c373.kamezawa.hiroyu@jp.fujitsu.com>
	<200811051208.26628.rjw@sisk.pl>
	<20081106091441.6517c072.kamezawa.hiroyu@jp.fujitsu.com>
	<1225931281.11514.27.camel@nimitz>
	<20081106095314.8e65f443.kamezawa.hiroyu@jp.fujitsu.com>
	<1225936986.6216.23.camel@nigel-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Tolentino <matthew.e.tolentino@intel.com>, Hansen <haveblue@us.ibm.com>, linux-pm@lists.osdl.org, Matt@smtp1.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave@smtp1.linux-foundation.org, Mel Gorman <mel@skynet.ie>, Andy@smtp1.linux-foundation.org, Whitcroft <apw@shadowen.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, pavel@suse.cz, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 06 Nov 2008 13:03:06 +1100
Nigel Cunningham <ncunningham@crca.org.au> wrote:

> Hi.
> 
> On Thu, 2008-11-06 at 09:53 +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 05 Nov 2008 16:28:01 -0800
> > Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > 
> > > On Thu, 2008-11-06 at 09:14 +0900, KAMEZAWA Hiroyuki wrote:
> > > > Ok, please consider "when memory hotplug happens." 
> > > > 
> > > > In general, it happens when
> > > >   1. memory is inserted to slot.
> > > >   2. the firmware notifes the system to enable already inserted memory.
> > > > 
> > > > To trigger "1", you have to open cover of server/pc. Do you open pc while the system
> > > > starts hibernation ? for usual people, no.
> > > 
> > > You're right, this won't happen very often.  We're trying to close a
> > > theoretical hole that hasn't ever been observed in practice.  But, we
> > > don't exactly leave races in code just because we haven't observed them.
> > > I think this is a classic race.
> > > 
> > > If we don't close it now, then someone doing some really weirdo hotplug
> > > is going to run into it at some point.  Who knows what tomorrow's
> > > hardware/firmware will do?
> > > 
> > Hmm, people tend to make crazy hardware, oh yes. the pc may fly in the sky with rocket engine.
> 
> It doesn't even have to be crazy. Just imagine someone bumping a button
> on the case while plugging in the memory and that button being
> configured to make the machine hibernate.
> 
please don't start hibernation if cover is open....(if you can)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
