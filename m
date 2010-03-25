Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 766FD6B01AD
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 23:29:33 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 4so1745717qwk.44
        for <linux-mm@kvack.org>; Wed, 24 Mar 2010 20:29:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <03ca01cacb92$195adf50$0400a8c0@dcccs>
References: <03ca01cacb92$195adf50$0400a8c0@dcccs>
Date: Thu, 25 Mar 2010 11:29:25 +0800
Message-ID: <2375c9f91003242029p1efbbea1v8e313e460b118f14@mail.gmail.com>
Subject: Re: Somebody take a look please! (some kind of kernel bug?)
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Janos Haar <janos.haar@netcenter.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(Cc'ing linux-mm)

2010/3/25 Janos Haar <janos.haar@netcenter.hu>:
> Dear developers,
>
> This is one of my productive servers, wich suddenly starts to freeze (cra=
sh)
> some weeks before.
> I have done all what i can, (i think) please somebody give to me some
> suggestion:
>
> Mar 24 19:22:28 alfa kernel: BUG: Bad page map in process httpd pte:2bf1e=
025
> pmd:1535b5067
> Mar 24 19:22:28 alfa kernel: page:ffffea0000f1b250 flags:4000000000000404
> count:1 mapcount:-1 mapping:(null) index:0
> Mar 24 19:22:28 alfa kernel: addr:00000037b4008000 vm_flags:08000875
> anon_vma:(null) mapping:ffff88022b5d25a8 index:8
> Mar 24 19:22:28 alfa kernel: vma->vm_ops->fault: filemap_fault+0x0/0x34d
> Mar 24 19:22:28 alfa kernel: vma->vm_file->f_op->mmap:
> xfs_file_mmap+0x0/0x33
> Mar 24 19:22:28 alfa kernel: Pid: 7512, comm: httpd Not tainted 2.6.32.10=
 #2
> Mar 24 19:22:28 alfa kernel: Call Trace:
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810c2ea3>] print_bad_pte+0x2=
10/0x229
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810c3c98>] unmap_vmas+0x44b/=
0x787
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810c81d5>] exit_mmap+0xb0/0x=
133
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81041f83>] mmput+0x48/0xb9
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810463b0>] exit_mm+0x105/0x1=
10
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81371287>] ?
> tty_audit_exit+0x28/0x85
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810477a0>] do_exit+0x1e9/0x6=
d2
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81053c37>] ?
> __dequeue_signal+0xf1/0x127
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81047d00>] do_group_exit+0x7=
7/0xa1
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810560f7>]
> get_signal_to_deliver+0x32c/0x37f
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff8100a484>]
> do_notify_resume+0x90/0x740
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff8102724b>] ?
> __bad_area_nosemaphore+0x178/0x1a2
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810272b9>] ? __bad_area+0x44=
/0x4d
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff8100bba2>] retint_signal+0x4=
6/0x84
> Mar 24 19:22:28 alfa kernel: Disabling lock debugging due to kernel taint
> Mar 24 19:22:28 alfa kernel: swap_free: Bad swap file entry 6c800000
> Mar 24 19:22:28 alfa kernel: BUG: Bad page map in process httpd
> pte:d900000000 pmd:1535b5067
> Mar 24 19:22:28 alfa kernel: addr:00000037b400a000 vm_flags:08000875
> anon_vma:(null) mapping:ffff88022b5d25a8 index:a
> Mar 24 19:22:28 alfa kernel: vma->vm_ops->fault: filemap_fault+0x0/0x34d
> Mar 24 19:22:28 alfa kernel: vma->vm_file->f_op->mmap:
> xfs_file_mmap+0x0/0x33
> Mar 24 19:22:28 alfa kernel: Pid: 7512, comm: httpd Tainted: G =C2=A0 =C2=
=A0B
> 2.6.32.10 #2
> Mar 24 19:22:28 alfa kernel: Call Trace:
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81044551>] ? add_taint+0x32/=
0x3e
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810c2ea3>] print_bad_pte+0x2=
10/0x229
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810c3d47>] unmap_vmas+0x4fa/=
0x787
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810c81d5>] exit_mmap+0xb0/0x=
133
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81041f83>] mmput+0x48/0xb9
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810463b0>] exit_mm+0x105/0x1=
10
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81371287>] ?
> tty_audit_exit+0x28/0x85
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810477a0>] do_exit+0x1e9/0x6=
d2
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81053c37>] ?
> __dequeue_signal+0xf1/0x127
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81047d00>] do_group_exit+0x7=
7/0xa1
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810560f7>]
> get_signal_to_deliver+0x32c/0x37f
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff8100a484>]
> do_notify_resume+0x90/0x740
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff8102724b>] ?
> __bad_area_nosemaphore+0x178/0x1a2
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810272b9>] ? __bad_area+0x44=
/0x4d
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff8100bba2>] retint_signal+0x4=
6/0x84
> Mar 24 19:22:28 alfa kernel: BUG: Bad page map in process httpd pte:2bfe8=
025
> pmd:1535b5067
> Mar 24 19:22:28 alfa kernel: page:ffffea0000f1f7c0 flags:4000000000000404
> count:1 mapcount:-1 mapping:(null) index:0
> Mar 24 19:22:28 alfa kernel: addr:00000037b400c000 vm_flags:08000875
> anon_vma:(null) mapping:ffff88022b5d25a8 index:c
> Mar 24 19:22:28 alfa kernel: vma->vm_ops->fault: filemap_fault+0x0/0x34d
> Mar 24 19:22:28 alfa kernel: vma->vm_file->f_op->mmap:
> xfs_file_mmap+0x0/0x33
> Mar 24 19:22:28 alfa kernel: Pid: 7512, comm: httpd Tainted: G =C2=A0 =C2=
=A0B
> 2.6.32.10 #2
> Mar 24 19:22:28 alfa kernel: Call Trace:
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81044551>] ? add_taint+0x32/=
0x3e
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810c2ea3>] print_bad_pte+0x2=
10/0x229
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810c3c98>] unmap_vmas+0x44b/=
0x787
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810c81d5>] exit_mmap+0xb0/0x=
133
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff81041f83>] mmput+0x48/0xb9
> Mar 24 19:22:28 alfa kernel: =C2=A0[<ffffffff810463b0>] exit_mm+0x105/0x1=
10
> .....
>
> The entire log is here:
> http://download.netcenter.hu/bughunt/20100324/messages
>
> The actual kernel is 2.6.32.10, but the crash-series started @ 2.6.28.10.
>
> I have forwarded the tasks to another server, removed this from the room,
> and the hw survived memtest86 in >7 days continously + i have tested the
> HDDs one by one with badblocks -vvw, all is good.
> For me looks like this is not a hw problem.
>
> Somebody have any idea?
>
> Thanks a lot,
> Janos Haar
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
