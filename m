Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 291B36B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 01:56:30 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so17683350pab.18
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 22:56:29 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id sz7si20807364pab.232.2014.02.18.22.56.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 22:56:29 -0800 (PST)
Message-ID: <5304558F.9050605@huawei.com>
Date: Wed, 19 Feb 2014 14:56:15 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: mm: OS boot failed when set command-line kmemcheck=1
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

Hi all,

CONFIG_KMEMCHECK=y and set command-line "kmemcheck=1", I find OS 
boot failed. The kernel is v3.14.0-rc3

If set "kmemcheck=1 nowatchdog", OS will boot successfully.

Here is the boot failed log:
[   23.586826] Freeing unused kernel memory: 1160K (ffff8800014de000 - ffff88000
1600000)
[   23.600248] Freeing unused kernel memory: 1696K (ffff880001858000 - ffff88000
1a00000)
[   23.615534] Kernel panic - not syncing: Attempted to kill init! exitcode=0x00
000005
[   23.615534]
[   23.624885] CPU: 0 PID: 1 Comm: init Tainted: G        W    3.14.0-rc3-0.1-de
fault+ #1
[   23.632957] Hardware name: Huawei Technologies Co., Ltd. Tecal RH2285
  /BC11BTSA              , BIOS CTSAV036 04/27/2011
[   23.644661]  ffff880c1dd28000 ffff880c1dd31c48 ffffffff814ca491 ffff880c1dd31
cc8
[   23.652416]  ffffffff814ca1e6 0000000000000010 ffff880c1dd31cd8 ffff880c1dd31
c78
[   23.660171]  0000000000000027 ffff880c1dcb8280 0000000000000005 ffff880c1dd28
000
[   23.667931] Call Trace:
[   23.670482]  [<ffffffff814ca491>] dump_stack+0x6a/0x79
[   23.675712]  [<ffffffff814ca1e6>] panic+0xb9/0x1f4
[   23.680599]  [<ffffffff8104f78e>] forget_original_parent+0x42e/0x430
[   23.687043]  [<ffffffff81107da0>] ? perf_cgroup_switch+0x170/0x170
[   23.693314]  [<ffffffff8104f7a1>] exit_notify+0x11/0x140
[   23.698722]  [<ffffffff8104fb00>] do_exit+0x230/0x490
[   23.703865]  [<ffffffff8104fda3>] do_group_exit+0x43/0xb0
[   23.709357]  [<ffffffff8105fb31>] get_signal_to_deliver+0x241/0x4b0
[   23.715713]  [<ffffffff81002a0c>] do_notify_resume+0xac/0x1a0
[   23.721551]  [<ffffffff814d712a>] int_signal+0x12/0x17
[   23.726786] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xf
fffffff80000000-0xffffffff9fffffff)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
