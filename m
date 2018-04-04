Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 536A76B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 12:18:48 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id r69so19935994ioe.20
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 09:18:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i33sor2316452ioo.58.2018.04.04.09.18.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 09:18:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180404121326.6eca4fa3@gandalf.local.home>
References: <20180404115310.6c69e7b9@gandalf.local.home> <20180404120002.6561a5bc@gandalf.local.home>
 <CAJWu+orC-1JDYHDTQU+DFckGq5ZnXBCCq9wLG-gNK0Nc4-vo7w@mail.gmail.com> <20180404121326.6eca4fa3@gandalf.local.home>
From: Joel Fernandes <joelaf@google.com>
Date: Wed, 4 Apr 2018 09:18:45 -0700
Message-ID: <CAJWu+op5-sr=2xWDYcd7FDBeMtrM9Zm96BgGzb4Q31UGBiU3ew@mail.gmail.com>
Subject: Re: [PATCH] ring-buffer: Add set/clear_current_oom_origin() during allocations
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Apr 4, 2018 at 9:13 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
[..]
>>
>> Also, I agree with the new patch and its nice idea to do that.
>
> Thanks, want to give it a test too?

Sure, I'll try it in a few hours. I am thinking of trying some of the
memory pressure tools we have. Likely by noon or so once I look at
some day job things :-D

thanks,

- Joel
