Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7F516B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 10:34:25 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id m6-v6so19198257pln.8
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 07:34:25 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 13si6158309pfm.246.2018.04.05.07.34.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 07:34:24 -0700 (PDT)
Date: Thu, 5 Apr 2018 10:34:21 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180405103421.60bcf53c@gandalf.local.home>
In-Reply-To: <20180405142749.GL6312@dhcp22.suse.cz>
References: <20180403093245.43e7e77c@gandalf.local.home>
	<20180403135607.GC5501@dhcp22.suse.cz>
	<CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
	<20180404062340.GD6312@dhcp22.suse.cz>
	<20180404101149.08f6f881@gandalf.local.home>
	<20180404142329.GI6312@dhcp22.suse.cz>
	<20180404114730.65118279@gandalf.local.home>
	<20180405025841.GA9301@bombadil.infradead.org>
	<CAJWu+oqP64QzvPM6iHtzowek6s4p+3rb7WDXs1z51mwW-9mLbA@mail.gmail.com>
	<20180405142258.GA28128@bombadil.infradead.org>
	<20180405142749.GL6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Joel Fernandes <joelaf@google.com>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, 5 Apr 2018 16:27:49 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> > I understand you don't want GFP_NORETRY.  But why is it more important for
> > this allocation to succeed than other normal GFP_KERNEL allocations?  
> 
> I guess they simply want a failure rather than OOM even when they can
> shoot themselves into head by using oom_origin. It is still quite ugly
> to see OOM report...

Exactly!

-- Steve
