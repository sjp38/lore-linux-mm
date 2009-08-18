Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7CB156B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 20:31:40 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7I0Vdco024281
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 18 Aug 2009 09:31:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2096A45DE80
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 09:31:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B11D45DE7E
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 09:31:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF455E08006
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 09:31:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3F7BE08013
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 09:31:36 +0900 (JST)
Date: Tue, 18 Aug 2009 09:29:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch 8/8] kexec: allow to shrink reserved memory
Message-Id: <20090818092939.2efbe158.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A8927DD.6060209@redhat.com>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
	<20090812081906.5757.39417.sendpatchset@localhost.localdomain>
	<m1bpmk8l1g.fsf@fess.ebiederm.org>
	<4A83893D.50707@redhat.com>
	<m1eirg5j9i.fsf@fess.ebiederm.org>
	<4A83CD84.8040609@redhat.com>
	<m1tz0avy4h.fsf@fess.ebiederm.org>
	<4A8927DD.6060209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Amerigo Wang <amwang@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Aug 2009 17:50:21 +0800
Amerigo Wang <amwang@redhat.com> wrote:

> Eric W. Biederman wrote:
> > Amerigo Wang <amwang@redhat.com> writes:
> >
> >   
> >> Not that simple, marking it as "__init" means it uses some "__init" data which
> >> will be dropped after initialization.
> >>     
> >
> > If we start with the assumption that we will be reserving to much and
> > will free the memory once we know how much we really need I see a very
> > simple way to go about this. We ensure that the reservation of crash
> > kernel memory is done through a normal allocation so that we have
> > struct page entries for every page.  On 32bit x86 that is an extra 1MB
> > for a 128MB allocation.
> >
> > Then when it comes time to release that memory we clear whatever magic
> > flags we have on the page (like PG_reserve) and call free_page.
> >   
> 
> Hmm, my MM knowledge is not good enough to judge if this works...
> I need to check more MM source code.
> 
> Can any MM people help?
> 
Hm, memory-hotplug guy is here.

Can I have a question ?

  - How crash kernel's memory is preserved at boot ?
    It's hidden from the system before mem_init() ?

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
