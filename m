Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2756C6B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 23:26:15 -0400 (EDT)
Received: by gxk20 with SMTP id 20so3559365gxk.14
        for <linux-mm@kvack.org>; Thu, 30 Apr 2009 20:26:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090428090129.17081.782.sendpatchset@rx1.opensource.se>
References: <20090428090129.17081.782.sendpatchset@rx1.opensource.se>
Date: Fri, 1 May 2009 12:26:38 +0900
Message-ID: <aec7e5c30904302026q42ecbd57m6e88c937bbd262bb@mail.gmail.com>
Subject: Re: [PATCH] videobuf-dma-contig: zero copy USERPTR support V2
From: Magnus Damm <magnus.damm@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-media@vger.kernel.org
Cc: hverkuil@xs4all.nl, linux-mm@kvack.org, Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 28, 2009 at 6:01 PM, Magnus Damm <magnus.damm@gmail.com> wrote:
> This is V2 of the V4L2 videobuf-dma-contig USERPTR zero copy patch.

I guess the V4L2 specific bits are pretty simple.

As for the minor mm modifications below,

> --- 0001/mm/memory.c
> +++ work/mm/memory.c =A0 =A02009-04-28 14:56:43.000000000 +0900
> @@ -3009,7 +3009,6 @@ int in_gate_area_no_task(unsigned long a
>
> =A0#endif /* __HAVE_ARCH_GATE_AREA */
>
> -#ifdef CONFIG_HAVE_IOREMAP_PROT
> =A0int follow_phys(struct vm_area_struct *vma,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long address, unsigned int flags,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long *prot, resource_size_t *phys=
)

Is it ok with the memory management guys to always build follow_phys()?

> @@ -3063,7 +3062,9 @@ unlock:
> =A0out:
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL(follow_phys);
>
> +#ifdef CONFIG_HAVE_IOREMAP_PROT
> =A0int generic_access_phys(struct vm_area_struct *vma, unsigned long addr=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *buf, int len, int wr=
ite)
> =A0{

How about exporting follow_phys()? This because the user
videobuf-dma-contig.c can be built as a module.

Should I use EXPORT_SYMBOL_GPL() instead of EXPORT_SYMBOL()?

Any comments?

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
