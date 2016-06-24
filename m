Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id E96916B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 11:21:57 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id v190so51845312vka.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 08:21:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k63si5232014qkc.107.2016.06.24.08.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 08:21:57 -0700 (PDT)
Date: Fri, 24 Jun 2016 10:21:53 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH v4 06/16] mm: Track NR_KERNEL_STACK in KiB instead of
 number of stacks
Message-ID: <20160624152153.k53i4m3iepoh4yax@treble>
References: <cover.1466741835.git.luto@kernel.org>
 <c2bc2ab30908b444e517b39ea1e22c9c057d5039.1466741835.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <c2bc2ab30908b444e517b39ea1e22c9c057d5039.1466741835.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jann Horn <jann@thejh.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Thu, Jun 23, 2016 at 09:23:01PM -0700, Andy Lutomirski wrote:
> Currently, NR_KERNEL_STACK tracks the number of kernel stacks in a
> zone.  This only makes sense if each kernel stack exists entirely in
> one zone, and allowing vmapped stacks could break this assumption.
> 
> Since frv has THREAD_SIZE < PAGE_SIZE, we need to track kernel stack
> allocations in a unit that divides both THREAD_SIZE and PAGE_SIZE on
> all architectures.  Keep it simple and use KiB.
> 
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-mm@kvack.org
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Josh Poimboeuf <jpoimboe@redhat.com>

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
