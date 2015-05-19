Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB1B6B0080
	for <linux-mm@kvack.org>; Tue, 19 May 2015 00:40:45 -0400 (EDT)
Received: by pdea3 with SMTP id a3so6843322pde.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 21:40:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id op8si19137284pac.123.2015.05.18.21.40.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 21:40:43 -0700 (PDT)
Message-ID: <555ABEBB.6060203@infradead.org>
Date: Mon, 18 May 2015 21:40:27 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: linux-next: Tree for May 18 (mm/memory-failure.c)
References: <20150518185226.23154d47@canb.auug.org.au> <555A0327.9060709@infradead.org> <20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

On 05/18/15 19:49, Naoya Horiguchi wrote:
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
> 
> Thanks,
> Naoya
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Subject: [PATCH] ras: hwpoison: fix build failure around
>  trace_memory_failure_event
> 
> next-20150515 fails to build on i386 with the following error:
> 
>   mm/built-in.o: In function `action_result':
>   memory-failure.c:(.text+0x344a5): undefined reference to `__tracepoint_memory_failure_event'
>   memory-failure.c:(.text+0x344d5): undefined reference to `__tracepoint_memory_failure_event'
>   memory-failure.c:(.text+0x3450c): undefined reference to `__tracepoint_memory_failure_event'
> 
> Defining CREATE_TRACE_POINTS and TRACE_INCLUDE_PATH fixes it.
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> ---
>  drivers/ras/ras.c       | 1 -
>  include/ras/ras_event.h | 2 ++
>  mm/memory-failure.c     | 1 +
>  3 files changed, 3 insertions(+), 1 deletion(-)


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
