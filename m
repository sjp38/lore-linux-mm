Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8066B0078
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 10:52:12 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id l9so392842eaj.0
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 07:52:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m44si9910725eeo.79.2013.12.06.07.52.10
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 07:52:11 -0800 (PST)
Date: Fri, 6 Dec 2013 16:52:38 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] Fix race between oom kill and task exit
Message-ID: <20131206155238.GA6676@redhat.com>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com> <20131128063505.GN3556@cmpxchg.org> <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com> <20131128120018.GL2761@dhcp22.suse.cz> <20131128183830.GD20740@redhat.com> <20131202141203.GA31402@redhat.com> <alpine.DEB.2.02.1312041655370.13608@chino.kir.corp.google.com> <20131205172931.GA26018@redhat.com> <alpine.DEB.2.02.1312051531330.7717@chino.kir.corp.google.com> <20131206151944.GC2674@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131206151944.GC2674@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Ma, Xindong" <xindong.ma@intel.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, gregkh@linuxfoundation.org, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>

On 12/06, Oleg Nesterov wrote:
>
> And this is risky. For example, 1/4 depends on (at least) another patch
> I sent in preparation for this change, commit 81907739851
> "kernel/fork.c:copy_process(): don't add the uninitialized
> child to thread/task/pid lists", perhaps on something else.

Hmm. not too much actually, I re-checked v3.10:kernel/copy_process.c.
Yes, list_add(thread_node)) in copy_process() can add the new thread
with the wrong pids, but somehow I forgot that list_add(thread_group)
in v3.10 has the same problem, so this probably doesn't matter and
we can safely backport this change.

> So personally I'd prefer to simply send the workaround for stable.

Yes, anyway, bacause I will sleep better ;)

But OK, if you think it would be better to mark 1-4 series I sent
for stable - I won't argue.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
