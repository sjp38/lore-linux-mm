Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 614756B012E
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 19:48:46 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6MNmmpb013405
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Jul 2009 08:48:48 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F6EB45DE53
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:48:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E8D2C45DE4F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:48:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D0DF71DB8042
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:48:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 837121DB8040
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:48:47 +0900 (JST)
Date: Thu, 23 Jul 2009 08:46:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] hibernate / memory hotplug: always use
 for_each_populated_zone()
Message-Id: <20090723084654.3076d3c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200907221949.56211.rjw@sisk.pl>
References: <1248103551.23961.0.camel@localhost.localdomain>
	<200907211611.09525.rjw@sisk.pl>
	<20090722092535.5eac1ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<200907221949.56211.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Nigel Cunningham <ncunningham@crca.org.au>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Jul 2009 19:49:55 +0200
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> > and enough simple. But this may allow you to access remapped device's memory...
> > Then, some range check will be required anyway.
> > Can we detect io-remapped range from memmap or any ?
> > (I think we'll have to skip PG_reserved page...)
> > 
> > > > Alternative is making use of walk_memory_resource() as memory hotplug does.
> > > > It checks resource information registered.
> > > 
> > > I'd be fine with any _simple_ mechanism allowing us to check whether there's
> > > a physical page frame for given page (or given PFN).
> > > 
> > 
> > walk_memory_resource() is enough _simple_,  IMHO.
> > Now, I'm removing #ifdef CONFIG_MEMORY_HOTPLUG for walk_memory_resource() to
> > rewrite /proc/kcore. 
> 
> Hmm.  Which architectures set CONFIG_ARCH_HAS_WALK_MEMORY ?
> 

ppc only. It has its own.

I'm now prepareing a patch to remove #ifdef CONFIG_MEMORY_HOTPLUG for /proc/kcore
and rename it to walk_system_ram_range(). plz see "kcore:...." patches currently
posted to lkml if you are interested in.

Thanks,
-Kame

Thanks,
-Kame


> Best,
> Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
