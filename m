Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD8B16B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 10:30:54 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o2-v6so16844037plk.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 07:30:54 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o69si6172430pfi.322.2018.04.05.07.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 07:30:53 -0700 (PDT)
Date: Thu, 5 Apr 2018 10:30:50 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180405103050.22f10319@gandalf.local.home>
In-Reply-To: <20180405142258.GA28128@bombadil.infradead.org>
References: <20180403123514.GX5501@dhcp22.suse.cz>
	<20180403093245.43e7e77c@gandalf.local.home>
	<20180403135607.GC5501@dhcp22.suse.cz>
	<CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
	<20180404062340.GD6312@dhcp22.suse.cz>
	<20180404101149.08f6f881@gandalf.local.home>
	<20180404142329.GI6312@dhcp22.suse.cz>
	<20180404114730.65118279@gandalf.local.home>
	<20180405025841.GA9301@bombadil.infradead.org>
	<CAJWu+oqP64QzvPM6iHtzowek6s4p+3rb7WDXs1z51mwW-9mLbA@mail.gmail.com>
	<20180405142258.GA28128@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Joel Fernandes <joelaf@google.com>, Michal Hocko <mhocko@kernel.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, 5 Apr 2018 07:22:58 -0700
Matthew Wilcox <willy@infradead.org> wrote:

> I understand you don't want GFP_NORETRY.  But why is it more important for
> this allocation to succeed than other normal GFP_KERNEL allocations?

Not sure what you mean by "more important"? Does saying "RETRY_MAYFAIL"
make it more important? The difference is, if GFP_KERNEL fails, we
don't want to trigger an OOM, and simply clean up and report -ENOMEM to
the user. It has nothing to do with being more important than other
allocations.

If there's 100 Megs of memory available, and the user requests a gig of
memory, it's going to fail. Ideally, it doesn't trigger OOM, but
instead simply reports -ENOMEM to the user.

-- Steve
