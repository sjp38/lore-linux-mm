Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 99B42900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 01:32:20 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so6978162pde.8
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 22:32:20 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id yl3si355481pbb.152.2014.10.27.22.32.17
        for <linux-mm@kvack.org>;
        Mon, 27 Oct 2014 22:32:19 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
References: <20141020215633.717315139@infradead.org>
	<20141021162340.GA5508@gmail.com>
	<20141021170948.GA25964@node.dhcp.inet.fi>
	<20141021175603.GI3219@twins.programming.kicks-ass.net>
	<5448DB05.5050803@cn.fujitsu.com>
	<20141023110438.GQ21513@worktop.programming.kicks-ass.net>
	<20141024075423.GA24479@gmail.com>
	<20141024131440.GZ21513@worktop.programming.kicks-ass.net>
Date: Tue, 28 Oct 2014 14:32:16 +0900
In-Reply-To: <20141024131440.GZ21513@worktop.programming.kicks-ass.net> (Peter
	Zijlstra's message of "Fri, 24 Oct 2014 15:14:40 +0200")
Message-ID: <87mw8g7o9r.fsf@sejong.aot.lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Peter,

On Fri, 24 Oct 2014 15:14:40 +0200, Peter Zijlstra wrote:
> On Fri, Oct 24, 2014 at 09:54:23AM +0200, Ingo Molnar wrote:
>> 
>> * Peter Zijlstra <peterz@infradead.org> wrote:
>> > Its what I thought initially, I tried doing perf record with and
>> > without, but then I ran into perf diff not quite working for me and I've
>> > yet to find time to kick that thing into shape.
>> 
>> Might be the 'perf diff' regression fixed by this:
>> 
>>   9ab1f50876db perf diff: Add missing hists__init() call at tool start
>> 
>> I just pushed it out into tip:master.
>
> I was on tip/master, so unlikely to be that as I was likely already
> having it.
>
> perf-report was affected too, for some reason my CONFIG_DEBUG_INFO=y
> vmlinux wasn't showing symbols (and I double checked that KASLR crap was
> disabled, so that wasn't confusing stuff either).
>
> When I forced perf-report to use kallsyms it works, however perf-diff
> doesn't have that option.
>
> So there's two issues there, 1) perf-report failing to generate useful
> output and 2) per-diff lacking options to force it to behave.

Did the perf-report fail to show any (kernel) symbols or are they wrong
symbols?  Maybe it's related to this:

https://lkml.org/lkml/2014/9/22/78

Thanks,
Namhyung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
