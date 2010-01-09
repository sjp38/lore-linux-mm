Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A3F0C6B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 20:03:23 -0500 (EST)
Received: by yxe36 with SMTP id 36so28933706yxe.11
        for <linux-mm@kvack.org>; Fri, 08 Jan 2010 17:03:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100108220533.23489.99121.stgit@warthog.procyon.org.uk>
References: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
	<20100108220533.23489.99121.stgit@warthog.procyon.org.uk>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 8 Jan 2010 19:55:48 -0500
Message-ID: <8bd0f97a1001081655s4ee3d4a7q3ef6a10d211ce6d1@mail.gmail.com>
Subject: Re: [PATCH 4/6] NOMMU: Don't need get_unmapped_area() for NOMMU
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, lethal@linux-sh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 8, 2010 at 17:05, David Howells wrote:
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
>
> +#ifdef CONFIG_MMU
> +extern void arch_pick_mmap_layout(struct mm_struct *mm);
> +#else
> +extern void arch_pick_mmap_layout(struct mm_struct *mm) {}
> +#endif

static inline instead of extern when !MMU ?
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
