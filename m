Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AFA376B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 08:57:57 -0400 (EDT)
Date: Fri, 8 May 2009 20:58:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: ftrace: concurrent accesses possible?
Message-ID: <20090508125821.GC15949@localhost>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090508114742.GB17129@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: =?utf-8?B?RnLDqWTDqXJpYw==?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

On Fri, May 08, 2009 at 07:47:42PM +0800, Ingo Molnar wrote:
> 
> So this should be done in cooperation with instrumentation folks, 
> while improving _all_ of Linux instrumentation in general. Or, if 
> you dont have the time/interest to work with us on that, it should 
> not be done at all. Not having the resources/interest to do 
> something properly is not a license to introduce further 
> instrumentation crap into Linux.

I have a dummy question on /debug/trace: is it possible to
- use 2+ tracers concurrently?
- run a system script that makes use of a tracer,
  without disturbing the sysadmin's tracer activities?
- access 1 tracer concurrently from many threads,
  with different filter etc. options?

If not currently, will private mounts be a viable solution?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
