Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id E05A082966
	for <linux-mm@kvack.org>; Thu, 21 May 2015 19:29:21 -0400 (EDT)
Received: by oiww2 with SMTP id w2so2068813oiw.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 16:29:21 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id j5si176733oef.53.2015.05.21.16.29.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 May 2015 16:29:21 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v6 0/5] tracing: add trace event for memory-failure
Date: Thu, 21 May 2015 23:28:22 +0000
Message-ID: <20150521232821.GA5502@hori1.linux.bs1.fc.nec.co.jp>
References: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
In-Reply-To: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <ACCB6EEEDDBEBD4EA57581AE87C8E9C2@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "rostedt@goodmis.org" <rostedt@goodmis.org>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "mingo@redhat.com" <mingo@redhat.com>, "bp@suse.de" <bp@suse.de>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "rdunlap@infradead.org" <rdunlap@infradead.org>, "jim.epost@gmail.com" <jim.epost@gmail.com>

On Thu, May 21, 2015 at 11:41:20AM +0800, Xie XiuQi wrote:
> RAS user space tools like rasdaemon which base on trace event, could
> receive mce error event, but no memory recovery result event. So, I
> want to add this event to make this scenario complete.
>=20
> This patchset add a event at ras group for memory-failure.
>=20
> The output like below:
> #  tracer: nop
> #
> #  entries-in-buffer/entries-written: 2/2   #P:24
> #
> #                               _-----=3D> irqs-off
> #                              / _----=3D> need-resched
> #                             | / _---=3D> hardirq/softirq
> #                             || / _--=3D> preempt-depth
> #                             ||| /     delay
> #            TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
> #               | |       |   ||||       |         |
>        mce-inject-13150 [001] ....   277.019359: memory_failure_event: pf=
n 0x19869: recovery action for free buddy page: Delayed
>=20
> --
> v5->v6:
>  - fix a build error
>  - move ras_event.h under include/trace/events
>  - rebase on top of latest mainline
>=20
> v4->v5:
>  - fix a typo
>  - rebase on top of latest mainline
>=20
> v3->v4:
>  - rebase on top of latest linux-next
>  - update comments as Naoya's suggestion
>  - add #ifdef CONFIG_MEMORY_FAILURE for this trace event
>  - change type of action_result's param 3 to enum
>=20
> v2->v3:
>  - rebase on top of linux-next
>  - based on Steven Rostedt's "tracing: Add TRACE_DEFINE_ENUM() macro
>    to map enums to their values" patch set v1.
>=20
> v1->v2:
>  - Comment update
>  - Just passing 'result' instead of 'action_name[result]',
>    suggested by Steve. And hard coded there because trace-cmd
>    and perf do not have a way to process enums.
>=20
> Naoya Horiguchi (1):
>   trace, ras: move ras_event.h under include/trace/events

I withdraw this patch because my assumption was wrong.

> Xie XiuQi (4):
>   memory-failure: export page_type and action result
>   memory-failure: change type of action_result's param 3 to enum
>   tracing: add trace event for memory-failure
>   tracing: fix build error in mm/memory-failure.c

This patchset depends on TRACE_DEFINE_ENUM patches, so base kernel version =
need
to be v4.1-rc1 or later. So please do the rebasing before merging this seri=
es.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
