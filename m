Subject: Re: 2.5.33-mm1
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <3D75CD24.AF9B769B@zip.com.au>
References: <3D75CD24.AF9B769B@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 04 Sep 2002 12:16:50 -0500
Message-Id: <1031159814.23852.21.camel@plars.austin.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I havn't tried this with stock 2.5.33 or 2.5.33-mm2 yet, but I was
trying the old fork07 ltp test and got a problem when I was testing
mm1.  The fork bomb part of that test is now in the fork12 test in LTP
and is not run by runalltests anymore due to the recent kernel changes. 
Here's the ksymoops output for now, and I'll see about trying to
reproduce it.

Thanks,
Paul Larson

Unable to handle kernel NULL pointer dereference at virtual address
00000004
c0131ef0
*pde = 28d4e001
Oops: 0002
CPU:    5
EIP:    0060:[<c0131ef0>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010046
eax: 00000000   ebx: c17a67b0   ecx: 00000000   edx: 00000000
esi: e8cd3000   edi: 00000000   ebp: cd0f8660   esp: e8d53d20
ds: 0068   es: 0068   ss: 0068
Stack: 00000001 e8d53de8 c17a67b0 c17a67b0 0000000f c0133b2d c17a67b0
00000001
       00000000 00000020 ed9fea24 00000000 c17ad5d8 c181aaa8 00000000
00000000
       e8dcf320 00000000 00000001 00000005 00000014 00000005 c01115f0
00000000
Call Trace: [<c0133b2d>] [<c01115f0>] [<c0109636>] [<c0107fba>]
[<c0134056>]
   [<c013cdda>] [<c013cd30>] [<c0134687>] [<c01346f1>] [<c013473e>]
[<c01353c3>]
   [<c0135712>] [<c0135790>] [<c0117747>] [<c01181e6>] [<c0107fba>]
[<c0118a43>]
   [<c0115b4d>] [<c01115f0>] [<c0105d47>] [<c01075f3>]
Code: 89 50 04 89 02 c7 06 00 00 00 00 c7 46 04 00 00 00 00 d3 24

>>EIP; c0131ef0 <kmem_shrink_slab+40/b0>   <=====
Trace; c0133b2d <shrink_list+cd/440>
Trace; c01115f0 <smp_apic_timer_interrupt+e0/120>
Trace; c0109636 <do_IRQ+f6/110>
Trace; c0107fba <apic_timer_interrupt+1a/20>
Trace; c0134056 <shrink_cache+1b6/320>
Trace; c013cdda <wakeup_bdflush+1a/20>
Trace; c013cd30 <background_writeout+0/90>
Trace; c0134687 <shrink_zone+87/c0>
Trace; c01346f1 <shrink_caches+31/50>
Trace; c013473e <try_to_free_pages+2e/70>
Trace; c01353c3 <balance_classzone+43/200>
Trace; c0135712 <__alloc_pages+192/200>
Trace; c0135790 <__get_free_pages+10/20>
Trace; c0117747 <dup_task_struct+17/80>
Trace; c01181e6 <copy_process+56/890>
Trace; c0107fba <apic_timer_interrupt+1a/20>
Trace; c0118a43 <do_fork+23/b0>
Trace; c0115b4d <schedule+33d/370>
Trace; c01115f0 <smp_apic_timer_interrupt+e0/120>
Trace; c0105d47 <sys_fork+17/30>
Trace; c01075f3 <syscall_call+7/b>
Code;  c0131ef0 <kmem_shrink_slab+40/b0>
00000000 <_EIP>:
Code;  c0131ef0 <kmem_shrink_slab+40/b0>   <=====
   0:   89 50 04                  mov    %edx,0x4(%eax)   <=====
Code;  c0131ef3 <kmem_shrink_slab+43/b0>
   3:   89 02                     mov    %eax,(%edx)
Code;  c0131ef5 <kmem_shrink_slab+45/b0>
   5:   c7 06 00 00 00 00         movl   $0x0,(%esi)
Code;  c0131efb <kmem_shrink_slab+4b/b0>
   b:   c7 46 04 00 00 00 00      movl   $0x0,0x4(%esi)
Code;  c0131f02 <kmem_shrink_slab+52/b0>
  12:   d3 24 00                  shll   %cl,(%eax,%eax,1)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
