From: Borislav Petkov <bp@alien8.de>
Subject: Re: [BUG] User process tainting in linux-next tree
Date: Sun, 29 Jun 2014 22:42:31 +0200
Message-ID: <20140629204231.GD12943@pd.tnic>
References: <CAC-LjFtjS5RS9=Lvb090-0aEnSdR1a28Scve2gvTR3yAZtt+9g@mail.gmail.com>
 <20140629191254.GA13271@pd.tnic>
 <CAC-LjFsF1qAVPKJeYmR0+6wTVmCwo2TkC8bia-KmxQ3wyUXYaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAC-LjFsF1qAVPKJeYmR0+6wTVmCwo2TkC8bia-KmxQ3wyUXYaw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Jeshwanth Kumar N K <jeshkumar555@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Hi,

first of all, please do not top-post. Here's why:

A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?
A: Top-posting.
Q: What is the most annoying thing in e-mail?

> Yes booted by increase the buffer length, but the ignore_loglevel is
> running continously for 5 minutes.

Huh, what? I can't parse that sentence above.

ignore_loglevel is another kernel cmdline parameter:

        ignore_loglevel [KNL]
                        Ignore loglevel setting - this will print /all/
                        kernel messages to the console. Useful for debugging.
                        We also add it as printk module parameter, so users
                        could change it dynamically, usually by
                        /sys/module/printk/parameters/ignore_loglevel.


> So I ignored that and ran with
> log_buf_len=500M ( because 10M also filled) only.
> 
> When I copied the dmesg, the size was 76M, so I attached only first
> 1500 lines. Please find in below link.
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=79171

Ok, that's better. The warnings start spewing pretty early with the one
below. Let's CC linux-mm.

[    1.062658] registered taskstats version 1
[    1.063400] ------------[ cut here ]------------
[    1.063455] WARNING: CPU: 0 PID: 55 at kernel/res_counter.c:28 res_counter_uncharge_until+0x84/0x110()
[    1.063513] Modules linked in:
[    1.063516] CPU: 0 PID: 55 Comm: modprobe Not tainted 3.16.0-rc1-next-20140620+ #4
[    1.063518] Hardware name: Dell Inc. Studio 1555/0C234M, BIOS A11 03/29/2010
[    1.063520]  00000000 00000000 d34d7de4 c1648de3 00000000 d34d7e14 c105b74e c1822e40
[    1.063524]  00000000 00000037 c183384f 0000001c c10dab24 c10dab24 d3c048c8 ffffffff
[    1.063529]  00000000 d34d7e24 c105b812 00000009 00000000 d34d7e58 c10dab24 00000282
[    1.063534] Call Trace:
[    1.063538]  [<c1648de3>] dump_stack+0x41/0x52
[    1.063541]  [<c105b74e>] warn_slowpath_common+0x7e/0xa0
[    1.063543]  [<c10dab24>] ? res_counter_uncharge_until+0x84/0x110
[    1.063546]  [<c10dab24>] ? res_counter_uncharge_until+0x84/0x110
[    1.063548]  [<c105b812>] warn_slowpath_null+0x22/0x30
[    1.063551]  [<c10dab24>] res_counter_uncharge_until+0x84/0x110
[    1.063553]  [<c10dabc1>] res_counter_uncharge+0x11/0x20
[    1.063557]  [<c117e975>] mem_cgroup_uncharge_end+0x85/0xa0
[    1.063560]  [<c113acb1>] release_pages+0x71/0x1c0
[    1.063563]  [<c1164072>] free_pages_and_swap_cache+0x92/0xb0
[    1.063567]  [<c1151b63>] tlb_flush_mmu_free+0x23/0x40
[    1.063570]  [<c11523cd>] tlb_flush_mmu+0x1d/0x30
[    1.063572]  [<c11523f1>] tlb_finish_mmu+0x11/0x40
[    1.063575]  [<c11588c7>] unmap_region+0x97/0xc0
[    1.063577]  [<c1158c22>] ? vma_rb_erase+0xe2/0x1b0
[    1.063580]  [<c115a8e3>] do_munmap+0x1c3/0x2d0
[    1.063582]  [<c115aa27>] vm_munmap+0x37/0x50
[    1.063584]  [<c115b710>] SyS_munmap+0x20/0x30
[    1.063588]  [<c1650318>] sysenter_do_call+0x12/0x28
[    1.063590] ---[ end trace 812035dd9a004e6c ]---

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
