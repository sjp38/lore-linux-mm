Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id D866F6B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 22:58:48 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 91-v6so4108409plf.6
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 19:58:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v24si5114987pff.274.2018.04.04.19.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Apr 2018 19:58:47 -0700 (PDT)
Date: Wed, 4 Apr 2018 19:58:41 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180405025841.GA9301@bombadil.infradead.org>
References: <20180403121614.GV5501@dhcp22.suse.cz>
 <20180403082348.28cd3c1c@gandalf.local.home>
 <20180403123514.GX5501@dhcp22.suse.cz>
 <20180403093245.43e7e77c@gandalf.local.home>
 <20180403135607.GC5501@dhcp22.suse.cz>
 <CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
 <20180404062340.GD6312@dhcp22.suse.cz>
 <20180404101149.08f6f881@gandalf.local.home>
 <20180404142329.GI6312@dhcp22.suse.cz>
 <20180404114730.65118279@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404114730.65118279@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Michal Hocko <mhocko@kernel.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, Apr 04, 2018 at 11:47:30AM -0400, Steven Rostedt wrote:
> I originally was going to remove the RETRY_MAYFAIL, but adding this
> check (at the end of the loop though) appears to have OOM consistently
> kill this task.
> 
> I still like to keep RETRY_MAYFAIL, because it wont trigger OOM if
> nothing comes in and tries to do an allocation, but instead will fail
> nicely with -ENOMEM.

I still don't get why you want RETRY_MAYFAIL.  You know that tries
*harder* to allocate memory than plain GFP_KERNEL does, right?  And
that seems like the exact opposite of what you want.
