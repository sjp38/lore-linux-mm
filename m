Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 57D8E6B00F5
	for <linux-mm@kvack.org>; Wed, 20 May 2015 02:10:11 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so56233703pdf.3
        for <linux-mm@kvack.org>; Tue, 19 May 2015 23:10:11 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id sg6si6016866pbc.146.2015.05.19.23.10.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 19 May 2015 23:10:09 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: linux-next: Tree for May 18 (mm/memory-failure.c)
Date: Wed, 20 May 2015 06:09:00 +0000
Message-ID: <20150520060900.GD27005@hori1.linux.bs1.fc.nec.co.jp>
References: <20150518185226.23154d47@canb.auug.org.au>
 <555A0327.9060709@infradead.org>
 <20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
 <555C1EA5.3080700@huawei.com>
In-Reply-To: <555C1EA5.3080700@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <0185EFAAAF411445A872DDB056396060@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

On Wed, May 20, 2015 at 01:41:57PM +0800, Xie XiuQi wrote:
...
>=20
> Hi Naoya,
>=20
> This patch will introduce another build error with attched config file.
>=20
> drivers/built-in.o:(__tracepoints+0x500): multiple definition of `__trace=
point_aer_event'
> mm/built-in.o:(__tracepoints+0x398): first defined here
> drivers/built-in.o:(__tracepoints+0x4ec): multiple definition of `__trace=
point_memory_failure_event'
> mm/built-in.o:(__tracepoints+0x384): first defined here
> drivers/built-in.o:(__tracepoints+0x514): multiple definition of `__trace=
point_mc_event'
> mm/built-in.o:(__tracepoints+0x3ac): first defined here
> drivers/built-in.o:(__tracepoints+0x528): multiple definition of `__trace=
point_extlog_mem_event'
> mm/built-in.o:(__tracepoints+0x3c0): first defined here
> make: *** [vmlinux] Error 1
>=20
> Is this one better?

Yes, thank you for digging.
I posted exactly the same patch just miniutes ago, but yours is a bit
earlier than mine, so you take the authorship :)

> ---
> From 99d91a901142b17287432b00169ac6bd9d87b489 Mon Sep 17 00:00:00 2001
> From: Xie XiuQi <xiexiuqi@huawei.com>
> Date: Thu, 21 May 2015 13:11:38 +0800
> Subject: [PATCH] tracing: fix build error in mm/memory-failure.c
>=20
> next-20150515 fails to build on i386 with the following error:
>=20
> mm/built-in.o: In function `action_result':
> memory-failure.c:(.text+0x344a5): undefined reference to `__tracepoint_me=
mory_failure_event'
> memory-failure.c:(.text+0x344d5): undefined reference to `__tracepoint_me=
mory_failure_event'
> memory-failure.c:(.text+0x3450c): undefined reference to `__tracepoint_me=
mory_failure_event'
>=20
> trace_memory_failure_event depends on CONFIG_RAS,
> so add 'select RAS' in mm/Kconfig to avoid this error.
>=20
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Chen Gong <gong.chen@linux.intel.com>
> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
