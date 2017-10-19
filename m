Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC7716B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:46:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 196so3971245wma.6
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 12:46:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 16sor665109wmw.69.2017.10.19.12.46.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Oct 2017 12:46:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171019193542.l5baqknxnfhljjkr@dhcp22.suse.cz>
References: <20171018231730.42754-1-shakeelb@google.com> <20171019123206.3etacullgnarbnad@dhcp22.suse.cz>
 <CALvZod40MmJ6F9ecKHsCkxyxnf_QR4pNqh55GENqqKKYpendMw@mail.gmail.com> <20171019193542.l5baqknxnfhljjkr@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 19 Oct 2017 12:46:50 -0700
Message-ID: <CALvZod5HcYVcGQff2Em_4uxqVm4rQMnO4RJYhJKQ-NtXzvO17g@mail.gmail.com>
Subject: Re: [PATCH] mm: mlock: remove lru_add_drain_all()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> [...]
>>
>> Sorry for the confusion. I wanted to say that if the pages which are
>> being mlocked are on caches of remote cpus then lru_add_drain_all will
>> move them to their corresponding LRUs and then remaining functionality
>> of mlock will move them again from their evictable LRUs to unevictable
>> LRU.
>
> yes, but the point is that we are draining pages which might be not
> directly related to pages which _will_ be mlocked by the syscall. In
> fact those will stay on the cache. This is the primary reason why this
> draining doesn't make much sense.
>
> Or am I still misunderstanding what you are saying here?
>

lru_add_drain_all() will drain everything irrespective if those pages
are being mlocked or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
