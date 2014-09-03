Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A55286B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 23:15:07 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id rd3so16433103pab.10
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 20:15:07 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id ci1si8596883pad.150.2014.09.02.20.15.06
        for <linux-mm@kvack.org>;
        Tue, 02 Sep 2014 20:15:06 -0700 (PDT)
Message-ID: <540687B9.7070305@sr71.net>
Date: Tue, 02 Sep 2014 20:15:05 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
References: <54061505.8020500@sr71.net> <20140902221814.GA18069@cmpxchg.org> <5406466D.1020000@sr71.net> <20140903001009.GA25970@cmpxchg.org> <CA+55aFw6ZkGNVX-CwyG0ybQAPjYAscdM59k_tOLtg4rr-fS-jg@mail.gmail.com> <20140903013317.GA26086@cmpxchg.org>
In-Reply-To: <20140903013317.GA26086@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 09/02/2014 06:33 PM, Johannes Weiner wrote:
> kfree isn't eating 56% of "all cpu time" here, and it wasn't clear to
> me whether Dave filtered symbols from only memcontrol.o, memory.o, and
> mmap.o in a similar way.  I'm not arguing against the regression, I'm
> just trying to make sense of the numbers from the *patched* kernel.

I guess I could have included it in the description, but that was a
pretty vanilla run:

	perf top --call-graph=fp --stdio > foo.txt

I didn't use any filtering.  I didn't even know I _could_ filter. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
