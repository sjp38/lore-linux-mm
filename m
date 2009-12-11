Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 159FF6B0088
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 22:22:14 -0500 (EST)
Received: by qyk15 with SMTP id 15so232681qyk.23
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 19:22:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0912100951130.31654@sister.anvils>
References: <2375c9f90912090238u7487019eq2458210aac4b602@mail.gmail.com>
	 <Pine.LNX.4.64.0912091442360.30748@sister.anvils>
	 <2375c9f90912092259pe86356cvb716232ba7a4d604@mail.gmail.com>
	 <Pine.LNX.4.64.0912100951130.31654@sister.anvils>
Date: Fri, 11 Dec 2009 11:22:11 +0800
Message-ID: <2375c9f90912101922g5b31e5c9gceeca299b9c2b656@mail.gmail.com>
Subject: Re: An mm bug in today's 2.6.32 git tree
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 10, 2009 at 5:56 PM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> On Thu, 10 Dec 2009, Am=C3=A9rico Wang wrote:
>> On Wed, Dec 9, 2009 at 10:49 PM, Hugh Dickins
>> >
>> > Thanks for the report. =C2=A0Not known to me.
>> > It looks like something has corrupted the start of a pagetable.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0no, not the start
>> > No idea what that something might be, but probably not bad RAM.
>> >
>> >>
>> >> Please feel free to let me know if you need more info.
>> >
>> > You say you saw it twice: please post what the other occasion
>> > showed (unless the first six lines were identical to this and it
>> > occurred around the same time i.e. separate report of the same).
>> >
>>
>> Yes, the rest are almost the same, the only difference is the 'addr'
>> shows different addresses.
>
> Please post what this other occasion showed, if you still have the log.

Sure, below is the whole thing.


Dec  9 17:36:31 dhcp-66-70-5 kernel: swap_free: Bad swap offset entry
7d80002f000080
Dec  9 17:36:31 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:fb00005e00010000 pmd:22f221067
Dec  9 17:36:31 dhcp-66-70-5 kernel: addr:000000319ce04000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:4
Dec  9 17:36:31 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:31 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:31 dhcp-66-70-5 kernel: Pid: 659, comm: vim Not tainted 2.6.32=
 #55
Dec  9 17:36:31 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff81118550>] ?
unmap_vmas+0x8bc/0xbd5
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:31 dhcp-66-70-5 kernel: Disabling lock debugging due to
kernel taint
Dec  9 17:36:31 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:8f3271e161f00 pmd:22f221067
Dec  9 17:36:31 dhcp-66-70-5 kernel: addr:000000319ce05000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:5
Dec  9 17:36:31 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:31 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:31 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:31 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:31 dhcp-66-70-5 kernel:  [<ffffffff81116dab>] ?
vm_normal_page+0x52/0x9f
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81118218>] ?
unmap_vmas+0x584/0xbd5
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:32 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:4000008b000045 pmd:22f221067
Dec  9 17:36:32 dhcp-66-70-5 kernel: page:ffffea0001e68000
flags:0100000000080010 count:0 mapcount:-1 mapping:(null) index:0
Dec  9 17:36:32 dhcp-66-70-5 kernel: addr:000000319ce06000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:6
Dec  9 17:36:32 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:32 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:32 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:32 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff8111840a>] ?
unmap_vmas+0x776/0xbd5
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:32 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:32 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:9541420a8f4e11ff pmd:22f221067
Dec  9 17:36:32 dhcp-66-70-5 kernel: addr:000000319ce07000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:7
Dec  9 17:36:32 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:32 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:33 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:33 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81116dd4>] ?
vm_normal_page+0x7b/0x9f
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81118218>] ?
unmap_vmas+0x584/0xbd5
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:33 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:e914e914fb0000e0 pmd:22f221067
Dec  9 17:36:33 dhcp-66-70-5 kernel: addr:000000319ce08000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:8
Dec  9 17:36:33 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:33 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:33 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:33 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff811184fe>] ?
unmap_vmas+0x86a/0xbd5
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:33 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:33 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:8400000ca47700 pmd:22f221067
Dec  9 17:36:34 dhcp-66-70-5 kernel: addr:000000319ce09000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:9
Dec  9 17:36:34 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:34 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:34 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:34 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81116dab>] ?
vm_normal_page+0x52/0x9f
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81118218>] ?
unmap_vmas+0x584/0xbd5
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:34 dhcp-66-70-5 kernel: swap_free: Unused swap offset
entry 00018000
Dec  9 17:36:34 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:03000000 pmd:22f221067
Dec  9 17:36:34 dhcp-66-70-5 kernel: addr:000000319ce0a000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:a
Dec  9 17:36:34 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:34 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:34 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:34 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81118550>] ?
unmap_vmas+0x8bc/0xbd5
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:34 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:34 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:43466e6169627609 pmd:22f221067
Dec  9 17:36:34 dhcp-66-70-5 kernel: addr:000000319ce0b000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:b
Dec  9 17:36:34 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:35 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:35 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:35 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81116dab>] ?
vm_normal_page+0x52/0x9f
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81118218>] ?
unmap_vmas+0x584/0xbd5
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:35 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:46873735f043231 pmd:22f221067
Dec  9 17:36:35 dhcp-66-70-5 kernel: addr:000000319ce0c000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:c
Dec  9 17:36:35 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:35 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:35 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:35 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81116dab>] ?
vm_normal_page+0x52/0x9f
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81118218>] ?
unmap_vmas+0x584/0xbd5
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:35 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:636f6c057063745f pmd:22f221067
Dec  9 17:36:35 dhcp-66-70-5 kernel: addr:000000319ce0d000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:d
Dec  9 17:36:35 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:35 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:35 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:35 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81116dd4>] ?
vm_normal_page+0x7b/0x9f
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81118218>] ?
unmap_vmas+0x584/0xbd5
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:35 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:1802100006c61 pmd:22f221067
Dec  9 17:36:35 dhcp-66-70-5 kernel: addr:000000319ce0e000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:e
Dec  9 17:36:35 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:35 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:35 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:35 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81116dd4>] ?
vm_normal_page+0x7b/0x9f
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81118218>] ?
unmap_vmas+0x584/0xbd5
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:35 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:35 dhcp-66-70-5 kernel: swap_free: Bad swap offset entry 09003=
c00
Dec  9 17:36:35 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:1200780000 pmd:22f221067
Dec  9 17:36:35 dhcp-66-70-5 kernel: addr:000000319ce0f000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:f
Dec  9 17:36:35 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:35 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:35 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:36 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81118550>] ?
unmap_vmas+0x8bc/0xbd5
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:36 dhcp-66-70-5 kernel: swap_free: Bad swap offset entry
30b4b13b048b00
Dec  9 17:36:36 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:6169627609160000 pmd:22f221067
Dec  9 17:36:36 dhcp-66-70-5 kernel: addr:000000319ce10000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:10
Dec  9 17:36:36 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:36 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:36 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:36 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81118550>] ?
unmap_vmas+0x8bc/0xbd5
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:36 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:c020c0323143466e pmd:22f221067
Dec  9 17:36:36 dhcp-66-70-5 kernel: addr:000000319ce11000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:11
Dec  9 17:36:36 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:36 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:36 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:36 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff811184fe>] ?
unmap_vmas+0x86a/0xbd5
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:36 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:1801c0037 pmd:22f221067
Dec  9 17:36:36 dhcp-66-70-5 kernel: page:ffffea0005406200
flags:0200000000000860 count:2 mapcount:-1 mapping:ffff88022ef96d70
index:143ed24
Dec  9 17:36:36 dhcp-66-70-5 kernel: addr:000000319ce12000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:12
Dec  9 17:36:36 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:36 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:36 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:36 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff8111840a>] ?
unmap_vmas+0x776/0xbd5
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:36 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:80fe100078 pmd:22f221067
Dec  9 17:36:36 dhcp-66-70-5 kernel: addr:000000319ce13000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:13
Dec  9 17:36:36 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:36 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:36 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:36 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:36 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff811184fe>] ?
unmap_vmas+0x86a/0xbd5
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:37 dhcp-66-70-5 kernel: swap_free: Bad swap offset entry
7f7f8b0f810000
Dec  9 17:36:37 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:feff161f02000000 pmd:22f221067
Dec  9 17:36:37 dhcp-66-70-5 kernel: addr:000000319ce14000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:14
Dec  9 17:36:37 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:37 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:37 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:37 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81118550>] ?
unmap_vmas+0x8bc/0xbd5
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:37 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:80010037c0f3271e pmd:22f221067
Dec  9 17:36:37 dhcp-66-70-5 kernel: addr:000000319ce15000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:15
Dec  9 17:36:37 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:37 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:37 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:37 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81116dab>] ?
vm_normal_page+0x52/0x9f
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81118218>] ?
unmap_vmas+0x584/0xbd5
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:37 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:a04007800000001 pmd:22f221067
Dec  9 17:36:37 dhcp-66-70-5 kernel: addr:000000319ce16000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:16
Dec  9 17:36:37 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:37 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:37 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:37 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81116dd4>] ?
vm_normal_page+0x7b/0x9f
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81118218>] ?
unmap_vmas+0x584/0xbd5
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:36:37 dhcp-66-70-5 kernel: BUG: Bad page map in process vim
pte:ef3352fe954142 pmd:22f221067
Dec  9 17:36:37 dhcp-66-70-5 kernel: addr:000000319ce17000
vm_flags:08000075 anon_vma:(null) mapping:ffff88022efa8848 index:17
Dec  9 17:36:37 dhcp-66-70-5 kernel: vma->vm_ops->fault: filemap_fault+0x0/=
0x593
Dec  9 17:36:37 dhcp-66-70-5 kernel: vma->vm_file->f_op->mmap:
generic_file_mmap+0x0/0x63
Dec  9 17:36:37 dhcp-66-70-5 kernel: Pid: 659, comm: vim Tainted: G
B      2.6.32 #55
Dec  9 17:36:37 dhcp-66-70-5 kernel: Call Trace:
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81116d32>] ?
print_bad_pte+0x29b/0x2c2
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81116dd4>] ?
vm_normal_page+0x7b/0x9f
Dec  9 17:36:37 dhcp-66-70-5 kernel:  [<ffffffff81118218>] ?
unmap_vmas+0x584/0xbd5
Dec  9 17:36:38 dhcp-66-70-5 kernel:  [<ffffffff8111eaf9>] ?
exit_mmap+0x13b/0x232
Dec  9 17:36:38 dhcp-66-70-5 kernel:  [<ffffffff810593de>] ? mmput+0x57/0x1=
23
Dec  9 17:36:38 dhcp-66-70-5 kernel:  [<ffffffff8105f8ce>] ? exit_mm+0x1af/=
0x1c1
Dec  9 17:36:38 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:38 dhcp-66-70-5 kernel:  [<ffffffff81061607>] ? do_exit+0x2f2/=
0xa61
Dec  9 17:36:38 dhcp-66-70-5 kernel:  [<ffffffff81089da6>] ? up_read+0x10/0=
x19
Dec  9 17:36:38 dhcp-66-70-5 kernel:  [<ffffffff81061e75>] ?
sys_exit_group+0x0/0x24
Dec  9 17:36:38 dhcp-66-70-5 kernel:  [<ffffffff81061e8e>] ?
sys_exit_group+0x19/0x24
Dec  9 17:36:38 dhcp-66-70-5 kernel:  [<ffffffff810039ab>] ?
system_call_fastpath+0x16/0x1b
Dec  9 17:37:57 dhcp-66-70-5 kernel: ------------[ cut here ]------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
