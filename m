Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90F956B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:33:44 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id k189so139754573vkg.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:33:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c2si17952620qtb.120.2016.06.16.08.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 08:33:43 -0700 (PDT)
Date: Thu, 16 Jun 2016 10:33:39 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH 04/13] mm: Track NR_KERNEL_STACK in pages instead of
 number of stacks
Message-ID: <20160616153339.xvlsnhksqmkeusn4@treble>
References: <cover.1466036668.git.luto@kernel.org>
 <24279d4009c821de64109055665429fad2a7bff7.1466036668.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <24279d4009c821de64109055665429fad2a7bff7.1466036668.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, x86@kernel.org, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Wed, Jun 15, 2016 at 05:28:26PM -0700, Andy Lutomirski wrote:
> Currently, NR_KERNEL_STACK tracks the number of kernel stacks in a
> zone.  This only makes sense if each kernel stack exists entirely in
> one zone, and allowing vmapped stacks could break this assumption.
> 
> It turns out that the code for tracking kernel stack allocations in
> units of pages is slightly simpler, so just switch to counting
> pages.
> 
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  fs/proc/meminfo.c | 2 +-
>  kernel/fork.c     | 3 ++-
>  mm/page_alloc.c   | 3 +--
>  3 files changed, 4 insertions(+), 4 deletions(-)

You missed another usage of NR_KERNEL_STACK in drivers/base/node.c.


-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
