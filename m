Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 845806B0038
	for <linux-mm@kvack.org>; Sat,  8 Oct 2016 04:05:32 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k16so35568554iok.5
        for <linux-mm@kvack.org>; Sat, 08 Oct 2016 01:05:32 -0700 (PDT)
Received: from out0-136.mail.aliyun.com (out0-136.mail.aliyun.com. [140.205.0.136])
        by mx.google.com with ESMTP id r124si6853815itg.109.2016.10.08.01.05.30
        for <linux-mm@kvack.org>;
        Sat, 08 Oct 2016 01:05:31 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <57F6BB8F.7070208@windriver.com>
In-Reply-To: <57F6BB8F.7070208@windriver.com>
Subject: Re: "swap_free: Bad swap file entry" and "BUG: Bad page map in process" but no swap configured
Date: Sat, 08 Oct 2016 16:05:27 +0800
Message-ID: <018601d2213a$bb0e44e0$312acea0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Chris Friesen' <chris.friesen@windriver.com>, 'lkml' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Friday, October 07, 2016 5:01 AM Chris Friesen
> 
> I have Linux host running as a kvm hypervisor.  It's running CentOS.  (So the
> kernel is based on 3.10 but with loads of stuff backported by RedHat.)  I
> realize this is not a mainline kernel, but I was wondering if anyone is aware of
> similar issues that had been fixed in mainline.
> 
Hey, dunno if you're looking for commit 
	6dec97dc929 ("mm: move_ptes -- Set soft dirty bit depending on pte type")
Hillf
> When doing a bunch of live migrations eventually I hit a bunch of errors that
> look like this.
> 
> 2016-10-03T23:13:54.017 controller-1 kernel: err [247517.457614] swap_free: Bad
> swap file entry 001fe858
> 2016-10-03T23:13:54.017 controller-1 kernel: alert [247517.463191] BUG: Bad page
> map in process qemu-kvm  pte:3fd0b000 pmd:4557cb067
> 2016-10-03T23:13:54.017 controller-1 kernel: alert [247517.471352]
> addr:00007fefa9be4000 vm_flags:00100073 anon_vma:ffff88043f87ff80 mapping:
>      (null) index:7fefa9be4
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483510] CPU: 0 PID:
> 154525 Comm: qemu-kvm Tainted: G           OE  ------------
> 3.10.0-327.28.3.7.tis.x86_64 #1
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483513] Hardware
> name: Intel Corporation S2600WT2R/S2600WT2R, BIOS
> SE5C610.86B.01.01.0016.033120161139 03/31/2016
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483516]
> 00007fefa9be4000 0000000007795eb9 ffff88044007bc60 ffffffff81670503
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483524]
> ffff88044007bca8 ffffffff8115e70f 000000003fd0b000 00000007fefa9be4
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483531]
> ffff8804557cbf20 000000003fd0b000 00007fefa9c00000 00007fefa9be4000
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483538] Call Trace:
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483548]
> [<ffffffff81670503>] dump_stack+0x19/0x1b
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483553]
> [<ffffffff8115e70f>] print_bad_pte+0x1af/0x250
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483557]
> [<ffffffff81160000>] unmap_page_range+0x5a0/0x7f0
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483561]
> [<ffffffff811602a9>] unmap_single_vma+0x59/0xd0
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483564]
> [<ffffffff81161595>] zap_page_range+0x105/0x170
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483568]
> [<ffffffff8115dd7c>] SyS_madvise+0x3bc/0x7d0
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483573]
> [<ffffffff810ca1e0>] ? SyS_futex+0x80/0x180
> 2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483577]
> [<ffffffff81678f89>] system_call_fastpath+0x16/0x1b
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
