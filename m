Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5CD6B0068
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 06:18:59 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so276568pab.40
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 03:18:59 -0800 (PST)
Received: from psmtp.com ([74.125.245.147])
        by mx.google.com with SMTP id xv7si2371203pab.172.2013.11.13.03.18.56
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 03:18:57 -0800 (PST)
Message-ID: <52836002.5050901@elastichosts.com>
Date: Wed, 13 Nov 2013 11:18:26 +0000
From: Alin Dobre <alin.dobre@elastichosts.com>
MIME-Version: 1.0
Subject: Re: Unnecessary mass OOM kills on Linux 3.11 virtualization host
References: <20131024224326.GA19654@alpha.arachsys.com> <20131025103946.GA30649@alpha.arachsys.com> <20131028082825.GA30504@alpha.arachsys.com>
In-Reply-To: <20131028082825.GA30504@alpha.arachsys.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On 28/10/13 08:28, Richard Davies wrote:
> I further attach some other types of memory manager errors found in the
> kernel logs around the same time. There are several occurrences of each, but
> I have only copied one here for brevity:
>
> 19:18:27 kernel: BUG: Bad page map in process qemu-system-x86  pte:00000608 pmd:1d57fd067
> 19:18:27 kernel: addr:00007f8150353000 vm_flags:80100073 anon_vma:ffff8817fc745a80 mapping:          (null) index:7f8150353
> 19:18:27 kernel: CPU: 2 PID: 29900 Comm: qemu-system-x86 Tainted: G    B        3.11.2-elastic #2
> 19:18:27 kernel: Hardware name: Supermicro H8DG6/H8DGi/H8DG6/H8DGi, BIOS 2.0b       03/01/2012
> 19:18:27 kernel: 00007f8150353000 ffff880b12d4dab8 ffffffff817ee7a6 ffff880807c8dba8
> 19:18:27 kernel: ffff880a03bb65c0 ffff880b12d4db08 ffffffff81135ed5 dead000000200200
> 19:18:27 kernel: 00000007f8150353 ffff880b12d4db08 00007f8150353000 ffff880a03bb65c0
> 19:18:27 kernel: Call Trace:
> 19:18:27 kernel: [<ffffffff817ee7a6>] dump_stack+0x55/0x86
> 19:18:27 kernel: [<ffffffff81135ed5>] print_bad_pte+0x1f5/0x213
> 19:18:27 kernel: [<ffffffff811379fd>] unmap_single_vma+0x509/0x6d6
> 19:18:27 kernel: [<ffffffff81138291>] unmap_vmas+0x4d/0x80
> 19:18:27 kernel: [<ffffffff8113e615>] exit_mmap+0x93/0x11e
> 19:18:27 kernel: [<ffffffff810bc2fb>] mmput+0x51/0xdb
> 19:18:27 kernel: [<ffffffff810c00b1>] do_exit+0x33c/0x8a2
> 19:18:27 kernel: [<ffffffff810c9779>] ? sigprocmask+0x5e/0x64
> 19:18:27 kernel: [<ffffffff810c7215>] ? __dequeue_signal+0x16/0x114
> 19:18:27 kernel: [<ffffffff810c06af>] do_group_exit+0x6a/0x9d
> 19:18:27 kernel: [<ffffffff810c956a>] get_signal_to_deliver+0x488/0x4a7
> 19:18:27 kernel: [<ffffffff81032db9>] do_signal+0x47/0x48f
> 19:18:27 kernel: [<ffffffff8110dc29>] ? rcu_eqs_enter+0x7d/0x82
> 19:18:27 kernel: [<ffffffff810e0ff4>] ? account_user_time+0x6a/0x95
> 19:18:27 kernel: [<ffffffff810e13b6>] ? vtime_account_user+0x5d/0x65
> 19:18:27 kernel: [<ffffffff81033229>] do_notify_resume+0x28/0x6a
> 19:18:27 kernel: [<ffffffff817f6358>] int_signal+0x12/0x17
>
>
> 19:18:33 kernel: BUG: Bad rss-counter state mm:ffff8817fb98bf00 idx:1 val:1
> 19:18:33 kernel: BUG: Bad rss-counter state mm:ffff8817fb98bf00 idx:2 val:-1

The above traces seem similar with the ones that were reported by Dave 
couple of months ago in the LKML thread https://lkml.org/lkml/2013/8/7/27.

Any further thoughts on why this happens?

Cheers,
Alin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
