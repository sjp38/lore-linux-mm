Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8B16B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 16:49:15 -0400 (EDT)
Date: Tue, 28 Apr 2009 22:54:03 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090428205403.GP27382@one.firstfloor.org>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu> <20090428083320.GB17038@localhost> <12c511ca0904281111r10f37a5coe5a2750f4dbfbcda@mail.gmail.com> <1240943671.938.575.camel@calx> <12c511ca0904281347m394b04e0mcb61f7c336752cc4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12c511ca0904281347m394b04e0mcb61f7c336752cc4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Tony Luck <tony.luck@gmail.com>
Cc: Matt Mackall <mpm@selenic.com>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 28, 2009 at 01:47:07PM -0700, Tony Luck wrote:
> On Tue, Apr 28, 2009 at 11:34 AM, Matt Mackall <mpm@selenic.com> wrote:
> > Bah. The rate of change is proportional to #cpus, not #pages. Assuming
> > you've got 1024 processors, you could run the scan in parallel in .2
> > seconds still.
> 
> That would help ... it would also make the patch to support this
> functionality a lot more complex.

I suspect 4TB memory users are used to some things running
a little slower. I'm not sure we really need to make every obscure
debugging functionality scale well to these systems too.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
