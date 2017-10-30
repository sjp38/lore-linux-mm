Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFE476B0253
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 04:51:43 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id l40so9398139uah.1
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 01:51:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x29sor5190531uai.224.2017.10.30.01.51.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Oct 2017 01:51:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1509126753-3297-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1509126753-3297-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 30 Oct 2017 19:51:42 +1100
Message-ID: <CAKTCnzn1-MMK+o-u2F3gcvCaq7Upk-5M2qOS9XaGV6-gcJRqBw@mail.gmail.com>
Subject: Re: [PATCH v2] pids: introduce find_get_task_by_vpid helper
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Sat, Oct 28, 2017 at 4:52 AM, Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> There are several functions that do find_task_by_vpid() followed by
> get_task_struct(). We can use a helper function instead.
>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---

I did a quick grep and found other similar patterns in
kernel/events/core.c, kernel/kcmp.c
kernel/sys.c , kernel/time/posix-cpu-timers.c,
arch/x86/kernel/cpu/intel_rdt_rdtgroup.c,
security/yama/yama_lsm.c, mm/process_vm_access.c, mm/mempolicy.c and
arch/ia64/kernel/perfmon.c


Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
