Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA69DZRq021732
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 18:13:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E20C845DD79
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 18:13:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E98045DD7B
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 18:13:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EDEE1DB803C
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 18:13:34 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EBCC1DB8038
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 18:13:34 +0900 (JST)
Date: Thu, 6 Nov 2008 18:12:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
 hotplug
Message-Id: <20081106181258.c9bb759c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081106091218.GA20574@atrey.karlin.mff.cuni.cz>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	<1225817945.12673.602.camel@nimitz>
	<20081105093837.e073c373.kamezawa.hiroyu@jp.fujitsu.com>
	<200811051208.26628.rjw@sisk.pl>
	<20081106091441.6517c072.kamezawa.hiroyu@jp.fujitsu.com>
	<20081106101751.14113f24.kamezawa.hiroyu@jp.fujitsu.com>
	<20081106091218.GA20574@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Dave Hansen <dave@linux.vnet.ibm.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nigel Cunningham <ncunningham@crca.org.au>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Nov 2008 10:12:18 +0100
Pavel Machek <pavel@suse.cz> wrote:

> > On Thu, 6 Nov 2008 09:14:41 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > Ok, please consider "when memory hotplug happens." 
> > > 
> > > In general, it happens when
> > >   1. memory is inserted to slot.
> > >   2. the firmware notifes the system to enable already inserted memory.
> > > 
> > > To trigger "1", you have to open cover of server/pc. Do you open pc while the system
> > > starts hibernation ? for usual people, no.
> > > 
> > > To trigger "2", the user have special console to tell firmware "enable this memory".
> > > Such firmware console or users have to know "the system works well." And, more important,
> > > when the system is suspended, the firmware can't do hotplug because the kernel is sleeping.
> > > So, such firmware console or operator have to know the system status.
> > > 
> > > Am I missing some ? Current linux can know PCI/USB hotplug while the system is suspended ?
> > > 
> > *OFFTOPIC*
> > 
> > I hear following answer from my friend.
> > 
> >   - hibernate the system
> > 	=> plug USB memory
> > 		=> wake up the system
> > 			=> panic.
> 
> That should work. File a bugzilla if it does not.
> 
> >   - hibernate the system
> > 	=> unplug USB memory
> > 		=> wake up the sytem
> > 			=> panic.
> 
> That should work ok as long as you unmount the drive first.
> 									Pavel
Ok. I'll confirm if I have a chance.
Sorry for rumor.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
