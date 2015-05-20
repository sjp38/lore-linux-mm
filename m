Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 113806B013F
	for <linux-mm@kvack.org>; Wed, 20 May 2015 16:03:23 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so80561834pdf.3
        for <linux-mm@kvack.org>; Wed, 20 May 2015 13:03:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w13si5548077pbt.221.2015.05.20.13.03.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 13:03:22 -0700 (PDT)
Date: Wed, 20 May 2015 13:03:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for May 18 (mm/memory-failure.c)
Message-Id: <20150520130320.1fc1bd7b1c26dae15c5946c5@linux-foundation.org>
In-Reply-To: <555C1EA5.3080700@huawei.com>
References: <20150518185226.23154d47@canb.auug.org.au>
	<555A0327.9060709@infradead.org>
	<20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
	<555C1EA5.3080700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

On Wed, 20 May 2015 13:41:57 +0800 Xie XiuQi <xiexiuqi@huawei.com> wrote:

> On 2015/5/19 10:49, Naoya Horiguchi wrote:
> > On Mon, May 18, 2015 at 08:20:07AM -0700, Randy Dunlap wrote:
> >> On 05/18/15 01:52, Stephen Rothwell wrote:
> >>> Hi all,
> >>>
> >>> Changes since 20150515:
> >>>
> >>
> >> on i386:
> >>
> >> mm/built-in.o: In function `action_result':
> >> memory-failure.c:(.text+0x344a5): undefined reference to `__tracepoint_memory_failure_event'
> >> memory-failure.c:(.text+0x344d5): undefined reference to `__tracepoint_memory_failure_event'
> >> memory-failure.c:(.text+0x3450c): undefined reference to `__tracepoint_memory_failure_event'
> > 
> > Thanks for the reporting, Randy.
> > Here is a patch for this problem, could you try it?
> 
> Hi Naoya,
> 
> This patch will introduce another build error with attched config file.
> 
> drivers/built-in.o:(__tracepoints+0x500): multiple definition of `__tracepoint_aer_event'
> mm/built-in.o:(__tracepoints+0x398): first defined here
> drivers/built-in.o:(__tracepoints+0x4ec): multiple definition of `__tracepoint_memory_failure_event'
> mm/built-in.o:(__tracepoints+0x384): first defined here
> drivers/built-in.o:(__tracepoints+0x514): multiple definition of `__tracepoint_mc_event'
> mm/built-in.o:(__tracepoints+0x3ac): first defined here
> drivers/built-in.o:(__tracepoints+0x528): multiple definition of `__tracepoint_extlog_mem_event'
> mm/built-in.o:(__tracepoints+0x3c0): first defined here
> make: *** [vmlinux] Error 1
> 
> Is this one better?

I'm lost.

I dropped

memory-failure-export-page_type-and-action-result.patch
memory-failure-change-type-of-action_results-param-3-to-enum.patch
tracing-add-trace-event-for-memory-failure.patch

Let's start again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
