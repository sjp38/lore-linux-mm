Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 351836B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 12:13:30 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o2-v6so12584274plk.14
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 09:13:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id az8-v6si3288857plb.665.2018.04.04.09.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 09:13:29 -0700 (PDT)
Date: Wed, 4 Apr 2018 12:13:26 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] ring-buffer: Add set/clear_current_oom_origin() during
 allocations
Message-ID: <20180404121326.6eca4fa3@gandalf.local.home>
In-Reply-To: <CAJWu+orC-1JDYHDTQU+DFckGq5ZnXBCCq9wLG-gNK0Nc4-vo7w@mail.gmail.com>
References: <20180404115310.6c69e7b9@gandalf.local.home>
	<20180404120002.6561a5bc@gandalf.local.home>
	<CAJWu+orC-1JDYHDTQU+DFckGq5ZnXBCCq9wLG-gNK0Nc4-vo7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, 4 Apr 2018 09:03:47 -0700
Joel Fernandes <joelaf@google.com> wrote:


> > for the tests. Note, without this, I tried to allocate all memory
> > (bisecting it with allocations that failed and allocations that
> > succeeded), and couldn't trigger an OOM :-/  
> 
> I guess you need to have something *else* other than the write to
> buffer_size_kb doing the GFP_KERNEL allocations but unfortunately gets
> OOM killed?

Yeah, for some reason, my test box seems to always have something doing
that, because I trigger an OOM about 2 out of every 3 tries.

Here's the tasks that trigger it:

 lvmetad, crond, systemd-journal, abrt-dump-journ, chronyd,

I guess my system is rather busy even when idle :-/

> 
> Also, I agree with the new patch and its nice idea to do that.

Thanks, want to give it a test too?

-- Steve
