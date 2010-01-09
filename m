Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 476296B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 19:57:41 -0500 (EST)
Received: by gxk24 with SMTP id 24so19890585gxk.6
        for <linux-mm@kvack.org>; Fri, 08 Jan 2010 16:57:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100108220538.23489.15477.stgit@warthog.procyon.org.uk>
References: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
	<20100108220538.23489.15477.stgit@warthog.procyon.org.uk>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 8 Jan 2010 19:57:20 -0500
Message-ID: <8bd0f97a1001081657p57d16013g73d0530c930bade6@mail.gmail.com>
Subject: Re: [PATCH 5/6] NOMMU: Fix race between ramfs truncation and shared
	mmap
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, lethal@linux-sh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 8, 2010 at 17:05, David Howells wrote:
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -389,7 +389,7 @@ arch_get_unmapped_area_topdown(struct file *filp, uns=
igned long addr,
> =C2=A0extern void arch_unmap_area(struct mm_struct *, unsigned long);
> =C2=A0extern void arch_unmap_area_topdown(struct mm_struct *, unsigned lo=
ng);
> =C2=A0#else
> -extern void arch_pick_mmap_layout(struct mm_struct *mm) {}
> +static inline void arch_pick_mmap_layout(struct mm_struct *mm) {}
> =C2=A0#endif

oh, i guess the static inline change was moved to this patch for some reaso=
n ...
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
