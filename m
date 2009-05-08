Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4EB6B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 07:47:21 -0400 (EDT)
Date: Fri, 8 May 2009 13:47:42 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/8] proc: export more page flags in /proc/kpageflags
Message-ID: <20090508114742.GB17129@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090508111031.020574236@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> Export all page flags faithfully in /proc/kpageflags.

Ongoing objection and NAK against extended haphazard exporting of 
kernel internals via an ad-hoc ABI via ad-hoc, privatized 
instrumentation that only helps the MM code and nothing else. It was 
a mistake to introduce the /proc/kpageflags hack a year ago, and it 
even more wrong today to expand on it.

/proc/kpageflags should be done via the proper methods outlined in 
the previous mails i wrote on this topic: for example by using the 
'object collections' abstraction i suggested. Clean enumeration of 
all pages (files, tasks, etc.) and the definition of histograms over 
it via free-form filter expressions is the right way to do this. It 
would not only help other subsystems, it would also be far more 
capable.

So this should be done in cooperation with instrumentation folks, 
while improving _all_ of Linux instrumentation in general. Or, if 
you dont have the time/interest to work with us on that, it should 
not be done at all. Not having the resources/interest to do 
something properly is not a license to introduce further 
instrumentation crap into Linux.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
