Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 395AB6B00ED
	for <linux-mm@kvack.org>; Wed, 20 May 2015 01:46:32 -0400 (EDT)
Received: by obfe9 with SMTP id e9so29019897obf.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 22:46:32 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id tf18si9990559oeb.20.2015.05.19.22.46.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 19 May 2015 22:46:31 -0700 (PDT)
Message-ID: <555C1EA5.3080700@huawei.com>
Date: Wed, 20 May 2015 13:41:57 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: linux-next: Tree for May 18 (mm/memory-failure.c)
References: <20150518185226.23154d47@canb.auug.org.au> <555A0327.9060709@infradead.org> <20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: multipart/mixed;
	boundary="------------090406060907010003060408"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

--------------090406060907010003060408
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit

On 2015/5/19 10:49, Naoya Horiguchi wrote:
> On Mon, May 18, 2015 at 08:20:07AM -0700, Randy Dunlap wrote:
>> On 05/18/15 01:52, Stephen Rothwell wrote:
>>> Hi all,
>>>
>>> Changes since 20150515:
>>>
>>
>> on i386:
>>
>> mm/built-in.o: In function `action_result':
>> memory-failure.c:(.text+0x344a5): undefined reference to `__tracepoint_memory_failure_event'
>> memory-failure.c:(.text+0x344d5): undefined reference to `__tracepoint_memory_failure_event'
>> memory-failure.c:(.text+0x3450c): undefined reference to `__tracepoint_memory_failure_event'
> 
> Thanks for the reporting, Randy.
> Here is a patch for this problem, could you try it?

Hi Naoya,

This patch will introduce another build error with attched config file.

drivers/built-in.o:(__tracepoints+0x500): multiple definition of `__tracepoint_aer_event'
mm/built-in.o:(__tracepoints+0x398): first defined here
drivers/built-in.o:(__tracepoints+0x4ec): multiple definition of `__tracepoint_memory_failure_event'
mm/built-in.o:(__tracepoints+0x384): first defined here
drivers/built-in.o:(__tracepoints+0x514): multiple definition of `__tracepoint_mc_event'
mm/built-in.o:(__tracepoints+0x3ac): first defined here
drivers/built-in.o:(__tracepoints+0x528): multiple definition of `__tracepoint_extlog_mem_event'
mm/built-in.o:(__tracepoints+0x3c0): first defined here
make: *** [vmlinux] Error 1

Is this one better?
---
--------------090406060907010003060408--
