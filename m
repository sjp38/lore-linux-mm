Received: by py-out-1112.google.com with SMTP id v53so1882156pyh
        for <linux-mm@kvack.org>; Sun, 20 May 2007 02:08:50 -0700 (PDT)
Message-ID: <1b5a37350705200208y20c8a23g90fd6adbdf665182@mail.gmail.com>
Date: Sun, 20 May 2007 10:08:49 +0100
From: "Ed Schofield" <edschofield@gmail.com>
Subject: BUG in mm/slab.c:777 __find_general_cachep()
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm getting a BUG in mm/slab.c upon boot for Linus's git tree from
Friday night (just before the 2.6.22-rc2 tag).

The call trace is:

[   29.543968] BUG: at mm/slab.c:777 __find_general_cachep()
[   29.543970]
[   29.543970] Call Trace:
[   29.543977]  [<ffffffff8028d8e5>] __kmalloc+0xd5/0x140
[   29.543981]  [<ffffffff8022064d>] cache_k8_northbridges+0x9d/0x120
[   29.543986]  [<ffffffff80582a13>] gart_iommu_init+0x33/0x5b0
[   29.543990]  [<ffffffff802e00cb>] sysfs_create_dir+0x2b/0x80
[   29.543993]  [<ffffffff80303d79>] kobject_shadow_add+0xb9/0x1f0
[   29.543996]  [<ffffffff80303b52>] kobject_get+0x12/0x20
[   29.544001]  [<ffffffff80383e77>] class_register+0x177/0x180
[   29.544004]  [<ffffffff8057dc6e>] pci_iommu_init+0xe/0x20
[   29.544008]  [<ffffffff805759c7>] kernel_init+0x157/0x330
[   29.544011]  [<ffffffff8020aca8>] child_rip+0xa/0x12
[   29.544015]  [<ffffffff80575870>] kernel_init+0x0/0x330
[   29.544017]  [<ffffffff8020ac9e>] child_rip+0x0/0x12
[   29.544019]

I've posted the output of dmesg, the kernel config, etc. here:

http://edschofield.com/linux/dmesg-2.6.22-rc1-g18963c01.log
http://edschofield.com/linux/config-2.6.22-rc1-g18963c01
http://edschofield.com/linux/lspci-2.6.22-rc1-g18963c01.log
http://edschofield.com/linux/iomem-2.6.22-rc1-g18963c01.log
http://edschofield.com/linux/ioports-2.6.22-rc1-g18963c01.log

If I can help with more information or testing, please let me know.

-- Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
