Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6C7D66B004D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 22:46:35 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C2kW7r010085
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 12 Mar 2009 11:46:33 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E38D45DE61
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:46:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 474D845DE51
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:46:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F7C8E38002
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:46:32 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D9F0DE18006
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:46:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
In-Reply-To: <alpine.DEB.2.00.0903111501070.3062@gandalf.stny.rr.com>
References: <20090311195601.47fe7798@mjolnir.ossman.eu> <alpine.DEB.2.00.0903111501070.3062@gandalf.stny.rr.com>
Message-Id: <20090312114503.43AB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 12 Mar 2009 11:46:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>, Pierre Ossman <drzeus@drzeus.cx>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> 
> On Wed, 11 Mar 2009, Pierre Ossman wrote:
> 
> > On Wed, 11 Mar 2009 14:48:02 -0400 (EDT)
> > Steven Rostedt <rostedt@goodmis.org> wrote:
> > 
> > > 
> > > Hmm, I assumed (but could be wrong) that on boot up, the system checked 
> > > how many CPUs were physically possible, and updated the possible CPU 
> > > mask accordingly (default being NR_CPUS).
> > > 
> > > If this is not the case, then I'll have to implement hot plug allocation. 
> > > :-/

Pierre, Could you please operate following command and post result?

# cat /sys/devices/system/cpu/possible


this is outputting the possible cpus of your system.



> > I have no idea, but every system doesn't suffer from this problem so
> > there is something more to this. Modern fedora kernels have NR_CPUS set
> > to 512, and it's not like I'm missing 1.5 GB here. :)
> > 
> 
> I'm thinking it is a system dependent feature. I'm working on implementing 
> the ring buffers to only allocate for online CPUS. I just realized that 
> there's a check of a ring buffer cpu mask to see if it is OK to write to 
> that CPU buffer. This works out perfectly, to keep non allocated buffers 
> from being written to.
> 
> Thanks,
> 
> -- Steve
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
