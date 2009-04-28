Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A031F6B004D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 14:34:45 -0400 (EDT)
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <12c511ca0904281111r10f37a5coe5a2750f4dbfbcda@mail.gmail.com>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu>
	 <20090428083320.GB17038@localhost>
	 <12c511ca0904281111r10f37a5coe5a2750f4dbfbcda@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 28 Apr 2009 13:34:31 -0500
Message-Id: <1240943671.938.575.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tony Luck <tony.luck@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-28 at 11:11 -0700, Tony Luck wrote:
> On Tue, Apr 28, 2009 at 1:33 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 1) FAST
> >
> > It takes merely 0.2s to scan 4GB pages:
> >
> >        ./page-types  0.02s user 0.20s system 99% cpu 0.216 total
> 
> OK on a tiny system ... but sounds painful on a big
> server. 0.2s for 4G scales up to 3 minutes 25 seconds
> on a 4TB system (4TB systems were being sold two
> years ago ... so by now the high end will have moved
> up to 8TB or perhaps 16TB).
> 
> Would the resulting output be anything but noise on
> a big system (a *lot* of pages can change state in
> 3 minutes)?

Bah. The rate of change is proportional to #cpus, not #pages. Assuming
you've got 1024 processors, you could run the scan in parallel in .2
seconds still.

It won't be an atomic snapshot, obviously. But stopping the whole
machine on a system that size is probably not what you want anyway.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
