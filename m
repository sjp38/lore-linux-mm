From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [PATCH 5/6] NOMMU: Fix race between ramfs truncation and shared
	mmap
Date: Fri, 8 Jan 2010 19:57:20 -0500
Message-ID: <8bd0f97a1001081657p57d16013g73d0530c930bade6__31846.2184550755$1262998689$gmane$org@mail.gmail.com>
References: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
	<20100108220538.23489.15477.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753532Ab0AIA5m@vger.kernel.org>
In-Reply-To: <20100108220538.23489.15477.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, lethal@linux-sh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Fri, Jan 8, 2010 at 17:05, David Howells wrote:
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -389,7 +389,7 @@ arch_get_unmapped_area_topdown(struct file *filp,=
 unsigned long addr,
> =C2=A0extern void arch_unmap_area(struct mm_struct *, unsigned long);
> =C2=A0extern void arch_unmap_area_topdown(struct mm_struct *, unsigne=
d long);
> =C2=A0#else
> -extern void arch_pick_mmap_layout(struct mm_struct *mm) {}
> +static inline void arch_pick_mmap_layout(struct mm_struct *mm) {}
> =C2=A0#endif

oh, i guess the static inline change was moved to this patch for some r=
eason ...
-mike
