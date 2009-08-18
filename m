Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A08CC6B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 19:58:53 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7INx0r7030379
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 19 Aug 2009 08:59:00 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 34F0F45DE54
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 08:59:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 110D745DE4D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 08:59:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E9C991DB8043
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 08:58:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 984421DB805B
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 08:58:59 +0900 (JST)
Date: Wed, 19 Aug 2009 08:57:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch 8/8] kexec: allow to shrink reserved memory
Message-Id: <20090819085703.ccf9992a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A8A83F4.6010408@redhat.com>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
	<20090812081906.5757.39417.sendpatchset@localhost.localdomain>
	<m1bpmk8l1g.fsf@fess.ebiederm.org>
	<4A83893D.50707@redhat.com>
	<m1eirg5j9i.fsf@fess.ebiederm.org>
	<4A83CD84.8040609@redhat.com>
	<m1tz0avy4h.fsf@fess.ebiederm.org>
	<4A8927DD.6060209@redhat.com>
	<20090818092939.2efbe158.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8A4ABB.70003@redhat.com>
	<20090818172552.779d0768.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8A83F4.6010408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Amerigo Wang <amwang@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Aug 2009 18:35:32 +0800
Amerigo Wang <amwang@redhat.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Tue, 18 Aug 2009 14:31:23 +0800
> > Amerigo Wang <amwang@redhat.com> wrote:
> >   
> >>>     It's hidden from the system before mem_init() ?
> >>>   
> >>>       
> >> Not sure, but probably yes. It is reserved in setup_arch() which is 
> >> before mm_init() which calls mem_init().
> >>
> >> Do you have any advice to free that reserved memory after boot? :)
> >>
> >>     
> >
> > Let's see arch/x86/mm/init.c::free_initmem()
> >
> > Maybe it's all you want.
> >
> > 	- ClearPageReserved()
> > 	- init_page_count()
> > 	- free_page()
> > 	- totalram_pages++
> >   
> 
> Just FYI: calling ClearPageReserved() caused an oops: "Unable to handle 
> paging request".
> 
> I am trying to figure out why...
> 
Hmm...then....memmap is not there.
pfn_valid() check will help you. What arch ? x86-64 ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
