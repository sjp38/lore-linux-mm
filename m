Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 62FFF6B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 20:20:56 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id la4so8135834vcb.9
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 17:20:56 -0700 (PDT)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id s10si254747vdv.68.2014.09.02.17.20.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 17:20:55 -0700 (PDT)
Received: by mail-vc0-f181.google.com with SMTP id ij19so7864746vcb.26
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 17:20:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140903001009.GA25970@cmpxchg.org>
References: <54061505.8020500@sr71.net>
	<20140902221814.GA18069@cmpxchg.org>
	<5406466D.1020000@sr71.net>
	<20140903001009.GA25970@cmpxchg.org>
Date: Tue, 2 Sep 2014 17:20:55 -0700
Message-ID: <CA+55aFw6ZkGNVX-CwyG0ybQAPjYAscdM59k_tOLtg4rr-fS-jg@mail.gmail.com>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Sep 2, 2014 at 5:10 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> That looks like a partial profile, where did the page allocator, page
> zeroing etc. go?  Because the distribution among these listed symbols
> doesn't seem all that crazy:

Please argue this *after* the commit has been reverted. You guys can
try to make the memcontrol batching actually work and scale later.
It's not appropriate to argue against major regressions when reported
and bisected by users.

Showing the spinlock at the top of the profile is very much crazy
(apparently taking 68% of all cpu time), when it's all useless
make-believe work. I don't understand why you wouldn't call that
crazy.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
