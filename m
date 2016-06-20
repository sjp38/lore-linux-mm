Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4EEBA6B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 12:05:46 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id i1so294670746vkg.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 09:05:46 -0700 (PDT)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id m16si6990501vka.199.2016.06.20.09.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 09:05:45 -0700 (PDT)
Received: by mail-vk0-x236.google.com with SMTP id d185so201611213vkg.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 09:05:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160620130232.GC9892@dhcp22.suse.cz>
References: <cover.1466192946.git.luto@kernel.org> <8a17889a9d47b7b4deb41f2fcccada8bf54d4b6f.1466192946.git.luto@kernel.org>
 <20160620130232.GC9892@dhcp22.suse.cz>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 20 Jun 2016 09:05:24 -0700
Message-ID: <CALCETrUhiFdNeE8BOcOYPDVLcDO6aq412iDT+Lf_9QHdmsY6Eg@mail.gmail.com>
Subject: Re: [PATCH v2 05/13] mm: Move memcg stack accounting to account_kernel_stack
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-arch <linux-arch@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Borislav Petkov <bp@alien8.de>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Brian Gerst <brgerst@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, X86 ML <x86@kernel.org>

On Jun 20, 2016 6:02 AM, "Michal Hocko" <mhocko@kernel.org> wrote:
>
> On Fri 17-06-16 13:00:41, Andy Lutomirski wrote:
> > We should account for stacks regardless of stack size.  Move it into
> > account_kernel_stack.
> >
> > Fixes: 12580e4b54ba8 ("mm: memcontrol: report kernel stack usage in cgroup2 memory.stat")
> > Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: linux-mm@kvack.org
> > Signed-off-by: Andy Lutomirski <luto@kernel.org>
>
> Acked-by: Michal Hocko <mhocko@suse.com>
>

This needs the same kilobyte treatment as the other accounting patch,
so I'm going to send v3 without your ack.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
