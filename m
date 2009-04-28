Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1D56B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 17:00:54 -0400 (EDT)
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <12c511ca0904281347m394b04e0mcb61f7c336752cc4@mail.gmail.com>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu>
	 <20090428083320.GB17038@localhost>
	 <12c511ca0904281111r10f37a5coe5a2750f4dbfbcda@mail.gmail.com>
	 <1240943671.938.575.camel@calx>
	 <12c511ca0904281347m394b04e0mcb61f7c336752cc4@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 28 Apr 2009 15:59:53 -0500
Message-Id: <1240952393.938.992.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tony Luck <tony.luck@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-28 at 13:47 -0700, Tony Luck wrote:
> On Tue, Apr 28, 2009 at 11:34 AM, Matt Mackall <mpm@selenic.com> wrote:
> > Bah. The rate of change is proportional to #cpus, not #pages. Assuming
> > you've got 1024 processors, you could run the scan in parallel in .2
> > seconds still.
> 
> That would help ... it would also make the patch to support this
> functionality a lot more complex.

The kernel bits should handle this already today. You just need 1k
userspace threads to open /proc/kpageflags, seek() appropriately, and
read().

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
