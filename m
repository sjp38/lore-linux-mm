Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 533CC60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:49:21 -0500 (EST)
Date: Wed, 9 Dec 2009 14:49:08 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: An mm bug in today's 2.6.32 git tree
In-Reply-To: <2375c9f90912090238u7487019eq2458210aac4b602@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0912091442360.30748@sister.anvils>
References: <2375c9f90912090238u7487019eq2458210aac4b602@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1942787429-1260370148=:30748"
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1942787429-1260370148=:30748
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 9 Dec 2009, Am=C3=A9rico Wang wrote:

> Hi, mm experts,
>=20
> I met the following bug in the kernel from today's git tree, accidentally=
=2E
> I don't know how to reproduce it, just saw it twice when doing different
> work. Machine is x86_64.
>=20
> Is this bug known?

Thanks for the report.  Not known to me.
It looks like something has corrupted the start of a pagetable.
No idea what that something might be, but probably not bad RAM.

>=20
> Please feel free to let me know if you need more info.

You say you saw it twice: please post what the other occasion
showed (unless the first six lines were identical to this and it
occurred around the same time i.e. separate report of the same).

Thanks,
Hugh

>=20
> Thanks!
>=20
> ----------------
> swap_free: Bad swap offset entry 09003c00
> BUG: Bad page map in process vim  pte:1200780000 pmd:22f221067
> addr:000000319ce0f000 vm_flags:08000075 anon_vma:(null)
> mapping:ffff88022efa8848 index:f
> vma->vm_ops->fault: filemap_fault+0x0/0x593
> vma->vm_file->f_op->mmap: generic_file_mmap+0x0/0x63
> Pid: 659, comm: vim Tainted: G    B      2.6.32 #55
> Call Trace:
>  [<ffffffff81116d32>] ? print_bad_pte+0x29b/0x2c2
>  [<ffffffff81118550>] ? unmap_vmas+0x8bc/0xbd5
>  [<ffffffff8111eaf9>] ? exit_mmap+0x13b/0x232
>  [<ffffffff810593de>] ? mmput+0x57/0x123
>  [<ffffffff8105f8ce>] ? exit_mm+0x1af/0x1c1
>  [<ffffffff81089da6>] ? up_read+0x10/0x19
>  [<ffffffff81061607>] ? do_exit+0x2f2/0xa61
>  [<ffffffff81089da6>] ? up_read+0x10/0x19
>  [<ffffffff81061e75>] ? sys_exit_group+0x0/0x24
>  [<ffffffff81061e8e>] ? sys_exit_group+0x19/0x24
>  [<ffffffff810039ab>] ? system_call_fastpath+0x16/0x1b
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
--8323584-1942787429-1260370148=:30748--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
