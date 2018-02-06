Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 066DF6B0003
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 19:14:52 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c142so161118wmh.4
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 16:14:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 133si5100705wmr.89.2018.02.05.16.14.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 16:14:50 -0800 (PST)
Date: Mon, 5 Feb 2018 16:14:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 198659] New: Kernel 4.14 crash wirh invalid opcode.
 list_del_entry_valid
Message-Id: <20180205161447.7370bb0ad2c2756da9fec81b@linux-foundation.org>
In-Reply-To: <bug-198659-27@https.bugzilla.kernel.org/>
References: <bug-198659-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, alexminder@gmail.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 04 Feb 2018 08:42:25 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=198659
> 
>             Bug ID: 198659
>            Summary: Kernel 4.14 crash wirh invalid opcode.
>                     list_del_entry_valid
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.14
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: alexminder@gmail.com
>         Regression: No
> 
> Created attachment 273983
>   --> https://bugzilla.kernel.org/attachment.cgi?id=273983&action=edit
> Kernel config
> 
> Guest KVM VM kernel (any version) crashes after some time after start if host
> Kernels version is 4.14.x.
> I tried host kernel versions: 4.14.8, 4.14.11, 4.14.13, 4.14.14, 4.14.15,
> 4.14.16. With all of them guest VM crashes.
> I tried nopti kernel parameter, but it does not help.
> I have configured kernel with CONFIG_PAGE_TABLE_ISOLATION=n and
> CONFIG_RETPOLINE=n and still have guest kernel crash.
> 
> With host kernel 4.13.x, 4.9.x no issue happens.
> I have note that kernel crashes under KVM guest only. With 4 my PC no kernel
> crashes.
> 
> [  531.309669] invalid opcode: 0000 [#1] SMP PTI
> [  531.309716] Modules linked in: netconsole rpcsec_gss_krb5 auth_rpcgss nfsv4
> dns_resolver nfs lockd grace fscache sunrpc binfmt_misc iTCO_wdt
> iTCO_vendor_support virtio_net virtio_balloon input_leds ghash_clmulni_intel
> led_class intel_agp lpc_ich intel_gtt i2c_i801 shpchp sd_mod ahci qxl
> virtio_scsi libahci drm_kms_helper xhci_pci syscopyarea sysfillrect xhci_hcd
> sysimgblt fb_sys_fops libata ttm usbcore virtio_pci virtio_ring drm scsi_mod
> virtio usb_common agpgart
> [  531.309928] CPU: 2 PID: 8946 Comm: cc1plus Not tainted 4.14.16 #1
> [  531.309960] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS
> 1.10.2-1.fc27 04/01/2014
> [  531.310001] task: ffff8b685eea9000 task.stack: ffffa37048e98000
> [  531.310034] RIP: 0010:__list_del_entry_valid+0x81/0x90
> [  531.310068] RSP: 0000:ffffa37048e9bbf8 EFLAGS: 00010082
> [  531.310097] RAX: 0000000000000054 RBX: 0000000000000370 RCX:
> 0000000000000000
> [  531.310141] RDX: 0000000000000000 RSI: ffff8b686ae96538 RDI:
> ffff8b686ae96538
> [  531.310176] RBP: ffff8b686b1f1000 R08: 0000000000000001 R09:
> 00000000000002ed
> [  531.310211] R10: 0000000000000000 R11: 00000000000002ed R12:
> 0000000000000010
> [  531.310255] R13: ffffa37048e9bd70 R14: 000000000000000a R15:
> ffffcdb700200020
> [  531.310291] FS:  00007f5193504c80(0000) GS:ffff8b686ae80000(0000)
> knlGS:0000000000000000
> [  531.310330] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  531.310359] CR2: 00007f5188d0a000 CR3: 000000011b376000 CR4:
> 00000000000406e0
> [  531.310396] Call Trace:
> [  531.312010]  ? __rmqueue+0xbd/0x570
> [  531.312048]  ? get_page_from_freelist+0xac9/0xbd0
> [  531.312076]  ? __alloc_pages_nodemask+0x103/0x260
> [  531.312102]  ? alloc_pages_vma+0x7c/0x1c0
> [  531.312127]  ? __handle_mm_fault+0xc53/0x1010
> [  531.312159]  ? handle_mm_fault+0xe4/0x190
> [  531.312189]  ? __do_page_fault+0x1c1/0x410
> [  531.312219]  ? async_page_fault+0x36/0x60
> [  531.312248]  ? async_page_fault+0x4c/0x60
> [  531.312276] Code: 00 43 d8 b7 e8 9f 0a c5 ff 0f 0b 48 89 fe 48 c7 c7 38 43
> d8 b7 e8 8e 0a c5 ff 0f 0b 48 89 fe 48 c7 c7 78 43 d8 b7 e8 7d 0a c5 ff <0f> 0b
> 90 90 90 90 90 90 90 90 90 90 90 90 90 48 85 d2 41 55 41
> [  531.312414] RIP: __list_del_entry_valid+0x81/0x90 RSP: ffffa37048e9bbf8
> [  531.312447] ---[ end trace 2dada20a9ff0080c ]---
> [  531.312473] Kernel panic - not syncing: Fatal exception
> [  532.344387] Shutting down cpus with NMI
> [  532.344453] Kernel Offset: 0x36000000 from 0xffffffff81000000 (relocation
> range: 0xffffffff80000000-0xffffffffbfffffff)
> [  532.344492] Rebooting in 1 seconds..
> [  533.359819] ACPI MEMORY or I/O RESET_REG.
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
