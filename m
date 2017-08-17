Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 738B16B02C3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 12:25:10 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b184so9169516oih.9
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 09:25:10 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id d124si2832863oif.272.2017.08.17.09.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 09:25:09 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id f11so71657204oic.0
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 09:25:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com> <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Aug 2017 09:25:08 -0700
Message-ID: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liang, Kan" <kan.liang@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Aug 17, 2017 at 9:17 AM, Liang, Kan <kan.liang@intel.com> wrote:
>
> We tried both 12 and 16 bit table and that didn't make a difference.
> The long wake ups are mostly on the same page when we do instrumentation

Ok.

> Here is the wake_up_page_bit call stack when the workaround is running, which
> is collected by perf record -g -a -e probe:wake_up_page_bit -- sleep 10

It's actually not really wake_up_page_bit() that is all that
interesting, it would be more interesting to see which path it is that
*adds* the entries.

So it's mainly wait_on_page_bit_common(), but also add_page_wait_queue().

Can you get that call stack instead (or in addition to)?

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
