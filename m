Return-Path: <SRS0=02Vf=PI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A811AC43387
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 07:06:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 454382133F
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 07:06:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Mv3P+MWX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 454382133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C18128E007D; Mon, 31 Dec 2018 02:06:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC7E18E005B; Mon, 31 Dec 2018 02:06:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB6EC8E007D; Mon, 31 Dec 2018 02:06:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 81B3D8E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 02:06:20 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id p4so30864917iod.17
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:06:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oAZ84qgDqZP6YlQX0c6kM+lrIjjHwvmjASiMHNI4PNc=;
        b=hz7gOn1oBSEh2Q8ulq4oc20PtN5r35Q36XBhuJie4k1N/dxrkn0PhMbX8wRTwjjSrO
         xiJVw7Am6ep7LZjp8m8stHnPg7ikbg+CbA7dI27iLIjJF6UqQ9Vd0LOyF/LB3TzLcmsP
         giPovjWUbF4+aE4RDfHRotWzODklp6MkMfOqtln4ajeAj89mUbI2YhbHDHJR/ZK09pkt
         imXRNUCsYPRGH4ZMqw0Q4iM2KCTzxFCZpfna3Yy6eVm8S5IJUbjkuN9+8sTDkDc4hQuj
         WYJs6HPq2IcCg+3DRd2+kd7cAlCBbhK8m49FxwOsrtkGI8JnDIghkYjB27FHVzqbJlGc
         J4cg==
X-Gm-Message-State: AJcUukd/pNv+bPiF2wHHzDcBAGE3cW2Sy8aCDXmiVksqzZlyK8bWAR7+
	TGXbnsU49KFYUoglX196bGM24PAOolIqeccFxFEWtrQOPCV77PUQJtY0xJAnEKm7VdO0BC/NVv9
	OhqPVGmaNjw+7JnMTn4uvUW6Sl3Cbp8/i49egSBADGMr1YF320Dan6Bc768UJ9CkD9Mleb/GiOG
	hmToFD9GVWPmQS0hr2AJjoYJURWS9w0XMyClN7HJ3tuDTwvoQjx641ykX71cZRin2hKHEpeMPgx
	l4I13ttoS0VwCczAWH6EI+F8JndpCUoIFPYT0UhZBaU8wkkChXfnG40bu6zzd+0gjInGYsH9x8I
	uGDyiJIbWPsa/ZYNksxIHrR/zdrD89QBoLraq8gelWMZW+aW39qq0G8daV1mdPYR/nbsW/7yjPs
	2
X-Received: by 2002:a5d:959a:: with SMTP id a26mr25337201ioo.278.1546239980214;
        Sun, 30 Dec 2018 23:06:20 -0800 (PST)
X-Received: by 2002:a5d:959a:: with SMTP id a26mr25337185ioo.278.1546239979403;
        Sun, 30 Dec 2018 23:06:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546239979; cv=none;
        d=google.com; s=arc-20160816;
        b=drWRjmE7qAcmtSdLXiPSOI2kSlPfDpdXDw3avdaJjMfOk9VcxhNnpXMxT07TmJGpGk
         ZS1/Yq02mOrBt2s+8LYu2ySXuMnPA/kE696oc/SYOXNEATgT/XA6s5+T36WHjuRelgO7
         8nSRDU+Y/DgjqPVGy36WawbzR5YZCQibGzEX6Z62le43fRpW3mT3NNAl5F3iTwt4J6up
         myUSWmuxR6e/7Q+Fe5/BpD0DLFRYZhdTQgUYwvguucx/a6KsnsgOyfsezecCXSUFAiBE
         ZqskCiof2w/uEl9SYJup9nNSm/pQv53eusXc1qyy6mk4KbktM/uMztenNKdt+U7uFsq4
         Q2UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oAZ84qgDqZP6YlQX0c6kM+lrIjjHwvmjASiMHNI4PNc=;
        b=rLghH6XHyUZnUolBP+fDzRI1FZa4zzf25Ig7ECL5Onr6AoxjKVtqlotNzzDwdsdnAB
         9THp+7nbqlC+4tC7C6tcWM4uNc7PbThnjfQ8xf64EsL2CLTp4mPNmdjA+3KyO0OY1cts
         g2CrF1GDPtG/IJP32iIERtju9jl+4/Y+bwbmtHz6ugxl394GRQGh2pC5L/2Sq1hTlhpX
         T5KOiB1eibNSenV6+ybpMfTNM+OR03PJDOUT087th0y/sF175Gtsp9ToFYXyXUgFutqX
         9fJHc+Y8xx8GCDrxNCVmhHwZTPj7P9hHiZi9L3tEjY4AJpF7J0lk8ufgpFOcpHy12sKx
         SIAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Mv3P+MWX;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor49243569jae.14.2018.12.30.23.06.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 23:06:19 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Mv3P+MWX;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oAZ84qgDqZP6YlQX0c6kM+lrIjjHwvmjASiMHNI4PNc=;
        b=Mv3P+MWXxy6us6a90uGTB3+iMacBzYgb0W8sY5SvVa5SaNpe4Ga1JgXWGQCVwKgkpF
         zADspdoOuKj+7Rg5WbqulottMWDOpqpilnSqy9SKTmMNJhRO3gaheJiV2AO8GfKiz3Yj
         sWw9RcleBT4maOMCj0lR3mbNmhW+2D+kJ10kfNciqp0FMdALBGyVqRMT8bnzpbXfwisB
         biwJWECRXh7zBBv0nDDLnJa1b0gh13Cub9zntRPN7T9zzPFMakyxHJScKPmRQOlxX8zP
         KJgRWM31xrV1mxpt/ravEfYKprshmDNeXlyasbBokyTCrZoj/CGKCNIybJKrcNZTFHtW
         IV+A==
X-Google-Smtp-Source: ALg8bN5/4zawAp3+Sl8Zkhrt5GnFV98sMMjAYQ5lSpW6UB4S0QlJEVPg1zkNflwr/xS3Pybg65JN6tYfNlS/ZtvxkA0=
X-Received: by 2002:a02:97a2:: with SMTP id s31mr11012595jaj.82.1546239978668;
 Sun, 30 Dec 2018 23:06:18 -0800 (PST)
MIME-Version: 1.0
References: <0000000000004fa95e057ca3b6c3@google.com>
In-Reply-To: <0000000000004fa95e057ca3b6c3@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 31 Dec 2018 08:06:07 +0100
Message-ID:
 <CACT4Y+ZjZqHUdTHGiphxUjZrmEOQgqJAw0dFxYivFQJkH06hyA@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in depot_save_stack
To: syzbot <syzbot+ed56d5a9b979d862fb67@syzkaller.appspotmail.com>
Cc: "'Dmitry Vyukov' via syzkaller-upstream-moderation" <syzkaller-upstream-moderation@googlegroups.com>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181231070607.oMGqKvYvMjY9EPQXOHnMJ9fVB-nMaKV8erWezt4E-hk@z>

On Mon, Dec 10, 2018 at 5:51 AM syzbot
<syzbot+ed56d5a9b979d862fb67@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    b72f711a4efa Merge branch 'spectre' of git://git.armlinux...
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=11eef243400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=b9cc5a440391cbfd
> dashboard link: https://syzkaller.appspot.com/bug?extid=ed56d5a9b979d862fb67
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> CC:             [gregkh@linuxfoundation.org linux-kernel@vger.kernel.org
> tj@kernel.org]
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+ed56d5a9b979d862fb67@syzkaller.appspotmail.com

Since this involves OOMs and looks like memory corruption:

#syz dup: kernel panic: corrupted stack end in wb_workfn

> IPVS: ftp: loaded support on port[0] = 21
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000009
> PGD 1b3eee067 P4D 1b3eee067 PUD 1b3eef067 PMD 0
> Oops: 0000 [#1] PREEMPT SMP KASAN
> CPU: 0 PID: 20236 Comm: syz-executor1 Not tainted 4.20.0-rc5+ #366
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:find_stack lib/stackdepot.c:188 [inline]
> RIP: 0010:depot_save_stack+0x121/0x470 lib/stackdepot.c:238
> Code: 0f 00 4e 8b 24 f5 20 0a 2e 8b 4d 85 e4 0f 84 d4 00 00 00 44 8d 47 ff
> 49 c1 e0 03 eb 0d 4d 8b 24 24 4d 85 e4 0f 84 bd 00 00 00 <41> 39 5c 24 08
> 75 ec 41 3b 7c 24 0c 75 e5 48 8b 01 49 39 44 24 18
> RSP: 0018:ffff888180156d08 EFLAGS: 00010202
> RAX: 0000000047977639 RBX: 00000000fef8ec23 RCX: ffff888180156d68
> RDX: 000000001e65b1bd RSI: 00000000006080c0 RDI: 0000000000000018
> RBP: ffff888180156d40 R08: 00000000000000b8 R09: 00000000dc2cc839
> R10: 00000000fafaa4f6 R11: ffff8881dae2dafb R12: 0000000000000001
> R13: ffff888180156d50 R14: 000000000008ec23 R15: ffff8881bba6641f
> FS:  0000000000d33940(0000) GS:ffff8881dae00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000009 CR3: 00000001b3ecd000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>   save_stack+0xa9/0xd0 mm/kasan/kasan.c:454
>   set_track mm/kasan/kasan.c:460 [inline]
>   kasan_kmalloc+0xc7/0xe0 mm/kasan/kasan.c:553
>   kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
>   slab_post_alloc_hook mm/slab.h:444 [inline]
>   slab_alloc mm/slab.c:3392 [inline]
>   kmem_cache_alloc+0x11b/0x730 mm/slab.c:3552
>   kmem_cache_zalloc include/linux/slab.h:731 [inline]
>   __kernfs_new_node+0x127/0x8d0 fs/kernfs/dir.c:634
>   kernfs_new_node+0x95/0x120 fs/kernfs/dir.c:695
>   __kernfs_create_file+0x5a/0x340 fs/kernfs/file.c:992
>   sysfs_add_file_mode_ns+0x222/0x530 fs/sysfs/file.c:306
>   sysfs_create_file_ns+0x1a3/0x270 fs/sysfs/file.c:331
>   sysfs_create_file include/linux/sysfs.h:513 [inline]
>   device_create_file+0xf4/0x1e0 drivers/base/core.c:1381
>   device_add+0x48c/0x18e0 drivers/base/core.c:1889
>   netdev_register_kobject+0x187/0x3f0 net/core/net-sysfs.c:1751
>   register_netdevice+0x99a/0x11d0 net/core/dev.c:8536
>   register_netdev+0x30/0x50 net/core/dev.c:8651
>   loopback_net_init+0x78/0x160 drivers/net/loopback.c:212
>   ops_init+0x101/0x560 net/core/net_namespace.c:129
>   setup_net+0x362/0x8d0 net/core/net_namespace.c:314
>   copy_net_ns+0x2b1/0x4a0 net/core/net_namespace.c:437
>   create_new_namespaces+0x6ad/0x900 kernel/nsproxy.c:107
>   unshare_nsproxy_namespaces+0xc3/0x1f0 kernel/nsproxy.c:206
>   ksys_unshare+0x79c/0x10b0 kernel/fork.c:2539
>   __do_sys_unshare kernel/fork.c:2607 [inline]
>   __se_sys_unshare kernel/fork.c:2605 [inline]
>   __x64_sys_unshare+0x31/0x40 kernel/fork.c:2605
>   do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x45a057
> Code: 00 00 00 b8 63 00 00 00 0f 05 48 3d 01 f0 ff ff 0f 83 fd 88 fb ff c3
> 66 2e 0f 1f 84 00 00 00 00 00 66 90 b8 10 01 00 00 0f 05 <48> 3d 01 f0 ff
> ff 0f 83 dd 88 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:0000000000a3ff78 EFLAGS: 00000202 ORIG_RAX: 0000000000000110
> RAX: ffffffffffffffda RBX: 00007f2516b77000 RCX: 000000000045a057
> RDX: 0000000000000006 RSI: 0000000000a3fa90 RDI: 0000000040000000
> RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000006
> R10: 0000000000000064 R11: 0000000000000202 R12: 0000000000000010
> R13: 0000000000412e50 R14: 0000000000000000 R15: 0000000000000000
> Modules linked in:
> CR2: 0000000000000009
> ---[ end trace 8ed3c6a41fc89e09 ]---
> RIP: 0010:find_stack lib/stackdepot.c:188 [inline]
> RIP: 0010:depot_save_stack+0x121/0x470 lib/stackdepot.c:238
> Code: 0f 00 4e 8b 24 f5 20 0a 2e 8b 4d 85 e4 0f 84 d4 00 00 00 44 8d 47 ff
> 49 c1 e0 03 eb 0d 4d 8b 24 24 4d 85 e4 0f 84 bd 00 00 00 <41> 39 5c 24 08
> 75 ec 41 3b 7c 24 0c 75 e5 48 8b 01 49 39 44 24 18
> RSP: 0018:ffff888180156d08 EFLAGS: 00010202
> RAX: 0000000047977639 RBX: 00000000fef8ec23 RCX: ffff888180156d68
> RDX: 000000001e65b1bd RSI: 00000000006080c0 RDI: 0000000000000018
> RBP: ffff888180156d40 R08: 00000000000000b8 R09: 00000000dc2cc839
> R10: 00000000fafaa4f6 R11: ffff8881dae2dafb R12: 0000000000000001
> R13: ffff888180156d50 R14: 000000000008ec23 R15: ffff8881bba6641f
> FS:  0000000000d33940(0000) GS:ffff8881dae00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000009 CR3: 00000001b3ecd000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> syzbot.
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-upstream-moderation" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-upstream-moderation+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-upstream-moderation/0000000000004fa95e057ca3b6c3%40google.com.
> For more options, visit https://groups.google.com/d/optout.

