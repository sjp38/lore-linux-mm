Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E3A43620002
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 23:56:37 -0500 (EST)
Received: by qyk14 with SMTP id 14so3684985qyk.11
        for <linux-mm@kvack.org>; Thu, 24 Dec 2009 20:56:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <f19d625d0912240309g5c066de7pc4dc9d95c084d4df@mail.gmail.com>
References: <f19d625d0912240309g5c066de7pc4dc9d95c084d4df@mail.gmail.com>
Date: Fri, 25 Dec 2009 12:56:36 +0800
Message-ID: <2375c9f90912242056h29f20dc5rb3f891c732e0d362@mail.gmail.com>
Subject: Re: 2.6.28.10 - kernel BUG at mm/rmap.c:725
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: CoolCold <coolthecold@gmail.com>
Cc: Linux kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk
List-ID: <linux-mm.kvack.org>

On Thu, Dec 24, 2009 at 7:09 PM, CoolCold <coolthecold@gmail.com> wrote:
> 3 days ago LA on server become very high and it was working very
> strange, so was rebooted. There are such entryies in log about kernel
> bug - kernel BUG at mm/rmap.c:725! . Googling didn't provide me with
> exact answer is it bug or hardware problems, something similar was
> here https://bugs.launchpad.net/ubuntu/+source/linux/+bug/252977/comments=
/56
> In general this server had number of unexpected stalls during several
> months, but there is no ipkvm, so i can't say where something on
> console or not. Hope you will help.
>
> Kernel version is 2.6.28.10 , self-builded. System - Debian stable/testin=
g.
>
> Please reply to me directly, cuz i'm not subsribed to list.
>
> Dec 21 22:05:01 gamma kernel: Eeek! page_mapcount(page) went negative! (-=
1)
> Dec 21 22:05:01 gamma kernel: =C2=A0 page pfn =3D 1f2c81
> Dec 21 22:05:01 gamma kernel: =C2=A0 page->flags =3D 20000000008007c
> Dec 21 22:05:01 gamma kernel: =C2=A0 page->count =3D 2
> Dec 21 22:05:01 gamma kernel: =C2=A0 page->mapping =3D ffff8801fd870b58
> Dec 21 22:05:01 gamma kernel: =C2=A0 vma->vm_ops =3D 0xffffffff80535020
> Dec 21 22:05:01 gamma kernel: =C2=A0 vma->vm_ops->fault =3D shmem_fault+0=
x0/0x69
> Dec 21 22:05:01 gamma kernel: =C2=A0 vma->vm_file->f_op->mmap =3D shmem_m=
map+0x0/0x2e
> Dec 21 22:05:01 gamma kernel: ------------[ cut here ]------------
> Dec 21 22:05:01 gamma kernel: kernel BUG at mm/rmap.c:725!

Hey,

commit 3dc147414cc already removed this BUG(), not sure
how serious this is...

Adding mm people into Cc.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
