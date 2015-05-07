Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2E51C6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 21:13:22 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so25597075pdb.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 18:13:21 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id sj10si557686pac.198.2015.05.06.18.13.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 06 May 2015 18:13:20 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 0/3] tracing: add trace event for memory-failure
Date: Thu, 7 May 2015 01:12:07 +0000
Message-ID: <20150507011207.GC7745@hori1.linux.bs1.fc.nec.co.jp>
References: <1429519480-11687-1-git-send-email-xiexiuqi@huawei.com>
 <5540BD13.1010408@huawei.com>
In-Reply-To: <5540BD13.1010408@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5CE273A685D82A4B8C45C001FCCEE05B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mingo@redhat.com" <mingo@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "hpa@linux.intel.com" <hpa@linux.intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "luto@amacapital.net" <luto@amacapital.net>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "bp@suse.de" <bp@suse.de>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>

On Wed, Apr 29, 2015 at 07:14:27PM +0800, Xie XiuQi wrote:
> Hi Naoya,
>=20
> Could you help to review and applied this series if possible.

Sorry for late response, I was offline for several days due to national
holidays.

This patchset is good to me, but I'm not sure which path it should go throu=
gh.
Ordinarily, memory-failure patches go to linux-mm, but patch 3 depends on
TRACE_DEFINE_ENUM patches, so this can go to linux-next directly, or go to
linux-mm with depending patches.

Steven, Andrew, which way do you like?

Thanks,
Naoya Horiguchi

> Thanks,
> Xie XiuQi
>=20
> On 2015/4/20 16:44, Xie XiuQi wrote:
> > RAS user space tools like rasdaemon which base on trace event, could
> > receive mce error event, but no memory recovery result event. So, I
> > want to add this event to make this scenario complete.
> >=20
> > This patchset add a event at ras group for memory-failure.
> >=20
> > The output like below:
> > #  tracer: nop
> > #
> > #  entries-in-buffer/entries-written: 2/2   #P:24
> > #
> > #                               _-----=3D> irqs-off
> > #                              / _----=3D> need-resched
> > #                             | / _---=3D> hardirq/softirq
> > #                             || / _--=3D> preempt-depth
> > #                             ||| /     delay
> > #            TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
> > #               | |       |   ||||       |         |
> >        mce-inject-13150 [001] ....   277.019359: memory_failure_event: =
pfn 0x19869: recovery action for free buddy page: Delayed
> >=20
> > --
> > v3->v4:
> >  - rebase on top of latest linux-next
> >  - update comments as Naoya's suggestion
> >  - add #ifdef CONFIG_MEMORY_FAILURE for this trace event
> >  - change type of action_result's param 3 to enum
> >=20
> > v2->v3:
> >  - rebase on top of linux-next
> >  - based on Steven Rostedt's "tracing: Add TRACE_DEFINE_ENUM() macro
> >    to map enums to their values" patch set v1.
> >=20
> > v1->v2:
> >  - Comment update
> >  - Just passing 'result' instead of 'action_name[result]',
> >    suggested by Steve. And hard coded there because trace-cmd
> >    and perf do not have a way to process enums.
> >=20
> > Xie XiuQi (3):
> >   memory-failure: export page_type and action result
> >   memory-failure: change type of action_result's param 3 to enum
> >   tracing: add trace event for memory-failure
> >=20
> >  include/linux/mm.h      |  34 ++++++++++
> >  include/ras/ras_event.h |  85 ++++++++++++++++++++++++
> >  mm/memory-failure.c     | 172 ++++++++++++++++++++--------------------=
--------
> >  3 files changed, 190 insertions(+), 101 deletions(-)
> >=20
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
