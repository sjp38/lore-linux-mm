Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B5D8D9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 00:49:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EA5103EE081
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:49:10 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D32B745DE7A
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:49:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B29FF45DE61
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:49:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A5A5C1DB803C
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:49:10 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6384D1DB802C
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 13:49:10 +0900 (JST)
Date: Thu, 29 Sep 2011 13:48:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V10 0/6] mm: frontswap: overview (and proposal to merge
 at next window)
Message-Id: <20110929134816.7f29bf46.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <22173398-de03-43ef-abe4-a3f3231dd2e9@default>
References: <20110915213305.GA26317@ca-server1.us.oracle.com
 20110928151558.dca1da5e.kamezawa.hiroyu@jp.fujitsu.com>
	<22173398-de03-43ef-abe4-a3f3231dd2e9@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Wed, 28 Sep 2011 07:09:18 -0700 (PDT)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> > Sent: Wednesday, September 28, 2011 12:16 AM
> > To: Dan Magenheimer
> > Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; jeremy@goop.org; hughd@google.com;
> > ngupta@vflare.org; Konrad Wilk; JBeulich@novell.com; Kurt Hackel; npiggin@kernel.dk; akpm@linux-
> > foundation.org; riel@redhat.com; hannes@cmpxchg.org; matthew@wil.cx; Chris Mason;
> > sjenning@linux.vnet.ibm.com; jackdachef@gmail.com; cyclonusj@gmail.com; levinsasha928@gmail.com
> > Subject: Re: [PATCH V10 0/6] mm: frontswap: overview (and proposal to merge at next window)
> > 
> > On Thu, 15 Sep 2011 14:33:05 -0700
> > Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
> > 
> > > [PATCH V10 0/6] mm: frontswap: overview (and proposal to merge at next window)
> > >
> > > (Note: V9->V10 only change is corrections in debugfs-related code/counters)
> > >
> > > (Note to earlier reviewers:  This patchset was reorganized at V9 due
> > > to feedback from Kame Hiroyuki and Andrew Morton.  Additionally, feedback
> > > on frontswap v8 from Andrew Morton also applies to cleancache, to wit:
> > >  (1) change usage of sysfs to debugfs to avoid unnecessary kernel ABIs
> > >  (2) rename all uses of "flush" to "invalidate"
> > > As a result, additional patches (5of6 and 6of6) were added to this
> > > series at V9 to patch cleancache core code and cleancache hooks in the mm
> > > and fs subsystems and update cleancache documentation accordingly.)
> > 
> > I'm sorry I couldn't catch following... what happens at hibernation ?
> > frontswap is effectively stopped/skipped automatically ? or contents of
> > TMEM can be kept after power off and it can be read correctly when
> > resume thread reads swap ?
> > 
> > In short: no influence to hibernation ?
> > I'm sorry if I misunderstand some.
> 
> Hi Kame --
> 
> Hibernation would need to be handled by the tmem backend (e.g. zcache, Xen
> tmem).  In the case of Xen tmem, both save/restore and live migration are
> fully supported.  I'm not sure if zcache works across hibernation; since
> all memory is kmalloc'ed, I think it should work fine, but it would be an
> interesting experiment.
> 

I'm afraid that users will lose data on memory of frontswap/zcache/tmem
by power-off, hibernation. How about adding internal hooks to disable/sync
frontswap itself before hibernation ? difficult ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
