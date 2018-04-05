Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91FB26B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 00:12:55 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 140-v6so1413020itg.4
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 21:12:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n2-v6sor4141itg.86.2018.04.04.21.12.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 21:12:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180405025841.GA9301@bombadil.infradead.org>
References: <20180403121614.GV5501@dhcp22.suse.cz> <20180403082348.28cd3c1c@gandalf.local.home>
 <20180403123514.GX5501@dhcp22.suse.cz> <20180403093245.43e7e77c@gandalf.local.home>
 <20180403135607.GC5501@dhcp22.suse.cz> <CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
 <20180404062340.GD6312@dhcp22.suse.cz> <20180404101149.08f6f881@gandalf.local.home>
 <20180404142329.GI6312@dhcp22.suse.cz> <20180404114730.65118279@gandalf.local.home>
 <20180405025841.GA9301@bombadil.infradead.org>
From: Joel Fernandes <joelaf@google.com>
Date: Wed, 4 Apr 2018 21:12:52 -0700
Message-ID: <CAJWu+oqP64QzvPM6iHtzowek6s4p+3rb7WDXs1z51mwW-9mLbA@mail.gmail.com>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Michal Hocko <mhocko@kernel.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Apr 4, 2018 at 7:58 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Wed, Apr 04, 2018 at 11:47:30AM -0400, Steven Rostedt wrote:
>> I originally was going to remove the RETRY_MAYFAIL, but adding this
>> check (at the end of the loop though) appears to have OOM consistently
>> kill this task.
>>
>> I still like to keep RETRY_MAYFAIL, because it wont trigger OOM if
>> nothing comes in and tries to do an allocation, but instead will fail
>> nicely with -ENOMEM.
>
> I still don't get why you want RETRY_MAYFAIL.  You know that tries
> *harder* to allocate memory than plain GFP_KERNEL does, right?  And
> that seems like the exact opposite of what you want.

No. We do want it to try harder but not if its already setup for failure.
