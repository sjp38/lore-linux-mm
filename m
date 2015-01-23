Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 347706B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 17:42:20 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id fb4so91495wid.2
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 14:42:19 -0800 (PST)
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id w10si5395975wiy.26.2015.01.23.14.42.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 14:42:18 -0800 (PST)
Received: by mail-wg0-f41.google.com with SMTP id a1so89955wgh.0
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 14:42:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150123202229.GA9038@node.dhcp.inet.fi>
References: <54BD33DC.40200@ti.com>
	<20150119174317.GK20386@saruman>
	<20150120001643.7D15AA8@black.fi.intel.com>
	<20150120114555.GA11502@n2100.arm.linux.org.uk>
	<20150120140546.DDCB8D4@black.fi.intel.com>
	<20150123172736.GA15392@kahuna>
	<CANMBJr7w2jZBwRDEsVNvL3XrDZ2ttwFz7qBf4zySAMMmcgAxiw@mail.gmail.com>
	<20150123183706.GA15791@kahuna>
	<20150123202229.GA9038@node.dhcp.inet.fi>
Date: Fri, 23 Jan 2015 14:42:17 -0800
Message-ID: <CANMBJr4YOcHj2G7w-gwfoZjQQd=h0Mj59QNBo3ei_=ejYRcdnw@mail.gmail.com>
Subject: Re: [next-20150119]regression (mm)?
From: Tyler Baker <tyler.baker@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Nishanth Menon <nm@ti.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Felipe Balbi <balbi@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linux-omap <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi Kirill,

On 23 January 2015 at 12:22, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> On Fri, Jan 23, 2015 at 12:37:06PM -0600, Nishanth Menon wrote:
>> On 09:39-20150123, Tyler Baker wrote:
>> > Hi,
>> >
>> > On 23 January 2015 at 09:27, Nishanth Menon <nm@ti.com> wrote:
>> > > On 16:05-20150120, Kirill A. Shutemov wrote:
>> > > [..]
>> > >> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> > >> Reported-by: Nishanth Menon <nm@ti.com>
>> > > Just to close on this thread:
>> > > https://github.com/nmenon/kernel-test-logs/tree/next-20150123 looks good
>> > > and back to old status. Thank you folks for all the help.
>> >
>> > I just reviewed the boot logs for next-20150123 and there still seems
>> > to be a related issue. I've been boot testing
>> > multi_v7_defconfig+CONFIG_ARM_LPAE=y kernel configurations which still
>> > seem broken.
>> >
>> > For example here are two boots with exynos5250-arndale, one with
>> > multi_v7_defconfig+CONFIG_ARM_LPAE=y [1] and the other with
>> > multi_v7_defconfig[2]. You can see the kernel configurations with
>> > CONFIG_ARM_LPAE=y show the splat:
>> >
>> > [   14.605950] ------------[ cut here ]------------
>> > [   14.609163] WARNING: CPU: 1 PID: 63 at ../mm/mmap.c:2858
>> > exit_mmap+0x1b8/0x224()
>> > [   14.616548] Modules linked in:
>> > [   14.619553] CPU: 1 PID: 63 Comm: init Not tainted 3.19.0-rc5-next-20150123 #1
>> > [   14.626713] Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
>> > [   14.632830] [] (unwind_backtrace) from [] (show_stack+0x10/0x14)
>> > [   14.640473] [] (show_stack) from [] (dump_stack+0x78/0x94)
>> > [   14.647678] [] (dump_stack) from [] (warn_slowpath_common+0x74/0xb0)
>> > [   14.655744] [] (warn_slowpath_common) from [] (warn_slowpath_null+0x1c/0x24)
>> > [   14.664510] [] (warn_slowpath_null) from [] (exit_mmap+0x1b8/0x224)
>> > [   14.672497] [] (exit_mmap) from [] (mmput+0x40/0xf8)
>> > [   14.679180] [] (mmput) from [] (flush_old_exec+0x328/0x604)
>> > [   14.686471] [] (flush_old_exec) from [] (load_elf_binary+0x26c/0x11f4)
>> > [   14.694715] [] (load_elf_binary) from [] (search_binary_handler+0x98/0x244)
>> > [   14.703395] [] (search_binary_handler) from []
>> > (do_execveat_common+0x4dc/0x5bc)
>> > [   14.712421] [] (do_execveat_common) from [] (do_execve+0x28/0x30)
>> > [   14.720235] [] (do_execve) from [] (ret_fast_syscall+0x0/0x34)
>> > [   14.727782] ---[ end trace 5e3ca48b454c7e0a ]---
>> > [   14.733758] ------------[ cut here ]------------
>> >
>> > Has anyone else tested with CONFIG_ARM_LPAE=y that can confirm my findings?
>> Uggh... I missed since i was looking at non LPAE omap2plus_defconfig.
>>
>> Dual A15 OMAP5432 with multi_v7_defconfig + CONFIG_ARM_LPAE=y
>> https://github.com/nmenon/kernel-test-logs/blob/next-20150123/multi_lpae_defconfig/omap5-evm.txt
>>
>> Dual A15 DRA7/AM572x with same configuration as above.
>> https://raw.githubusercontent.com/nmenon/kernel-test-logs/next-20150123/multi_lpae_defconfig/dra7xx-evm.txt
>> https://github.com/nmenon/kernel-test-logs/blob/next-20150123/multi_lpae_defconfig/am57xx-evm.txt
>>
>> Single A15 DRA72 with same configuration as above:
>> https://raw.githubusercontent.com/nmenon/kernel-test-logs/next-20150123/multi_lpae_defconfig/dra72x-evm.txt
>>
>> You are right. the issue re-appears with LPAE on :(
>> Apologies on missing that.
>
> Guys, could you instrument mm_{inc,dec}_nr_pmds() with dump_stack() +
> printk() of the counter and add printk() on mmap_exit() then run a simple
> program which triggers the issue?

For reference, here is the patch I've applied for testing, mostly
stolen from Felipe's debug patch above in this thread.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1fbd0e8..e5b0444 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1455,11 +1455,17 @@ static inline unsigned long mm_nr_pmds(struct
mm_struct *mm)
 static inline void mm_inc_nr_pmds(struct mm_struct *mm)
 {
        atomic_long_inc(&mm->nr_pmds);
+        dump_stack();
+        printk(KERN_INFO "===> %s nr_pmds %ld\n", __func__,
+                atomic_long_read(&mm->nr_pmds));
 }

 static inline void mm_dec_nr_pmds(struct mm_struct *mm)
 {
        atomic_long_dec(&mm->nr_pmds);
+        dump_stack();
+        printk(KERN_INFO "===> %s nr_pmds %ld\n", __func__,
+                atomic_long_read(&mm->nr_pmds));
 }
 #endif

diff --git a/mm/mmap.c b/mm/mmap.c
index 6a7d36d..a16471f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2809,6 +2809,7 @@ EXPORT_SYMBOL(vm_brk);
 /* Release all mmaps. */
 void exit_mmap(struct mm_struct *mm)
 {
+       printk(KERN_INFO "===> %s exit_mmap enter\n", __func__);
        struct mmu_gather tlb;
        struct vm_area_struct *vma;
        unsigned long nr_accounted = 0;

I applied this patch to the tip of linux-next, configured for
multi_v7_defconfig and set CONFIG_ARM_LPAE=y. The log for this arndale
boot can be found here [1]. For good measure, I then rebuilt the
kernel with CONFIG_ARM_LPAE=n and booted the same platform again. This
log can be found here [2].

Happy hunting!

>
> --
>  Kirill A. Shutemov

[1] http://storage.kernelci.org/debug/mm/arndale-lpae-debug-next-20150123.html
[2] http://storage.kernelci.org/debug/mm/arndale-no-lpae-debug-next-20150123.html

Cheers,

Tyler

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
