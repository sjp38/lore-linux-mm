Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3334FC43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 11:54:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFFB4218D9
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 11:54:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="inIW1Yol"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFFB4218D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47F468E001F; Wed,  2 Jan 2019 06:54:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42E3B8E0002; Wed,  2 Jan 2019 06:54:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31D558E001F; Wed,  2 Jan 2019 06:54:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 08D5C8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 06:54:16 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id t133so35735300iof.20
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 03:54:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5YY/Z6WD5GCTh40GRusn11FiGIKlWnJ9nbkQK6HHmW4=;
        b=R/NFlnuQqDI60utTfQNQxfa/D6xXzrFzaVZve2mXZvPvdowAl0TN584kXqm8rRbnlv
         FsMCdzza2fp7UyeevxLn/VMgkvvr/QqmOywUTsXq+hfYnxZvr5Khbtex2vIer66fRW48
         qNjEHalaP9w1JupN7mvNUys+lAtRS+H67hF3PgcALTO1SUDuUGkqqAuog8IanWLhW3iu
         PxIzJgKVtQTdxnG/3P2ZAVMKD5lsHjeZ5/LWFxB7vB7XJDW+PrjaGU4SsdlyGKy9VOlk
         oAp4VIVc0asWGcWqyUyKpzFIaZqP+XTbIYSme/vaIv36M3w3TY5tcWU0rKTAl2f8OtaO
         Zb+Q==
X-Gm-Message-State: AA+aEWZkBijrFnt51HvfrzTsqvDg+qD+GntgJr3V7nKJUQqRQNMsXX9d
	5pNE3p0gXwqublwThfXpl/J0F9WFksrm5YuOkJsgdgQHyYheH7qcL1G/couVPKhvX0XL8hpyC61
	TCKmam8iT2kQnJJ5QOnLa+nIYoUViE7pFI9Fpfa/Gg3SR8+UnqRBG+mvIIrTVTcmXMLuSkdTb8q
	FBR6t6WQYa3t8rxiWhoTzhm9Ig9bSfq1pW1lWVcf7ePSuywX5V1CouTxSTGpr0PiLewxCrrnw63
	kBHQSkqOFJmyeercXsQ5U5tirJK1H7kkuhMQKQXBJ2hGI6quvt48xmN2qh1DkYOwR62AGskoBpF
	ks8vq11cJ9qyXHJSd2JEk/r4Mbv1UlNdA3ucKydmXwSQZKRCkhymtEnzlAwlTPGYGPEgNQrqIwc
	A
X-Received: by 2002:a24:f143:: with SMTP id q3mr29012674iti.42.1546430055659;
        Wed, 02 Jan 2019 03:54:15 -0800 (PST)
X-Received: by 2002:a24:f143:: with SMTP id q3mr29012650iti.42.1546430054666;
        Wed, 02 Jan 2019 03:54:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546430054; cv=none;
        d=google.com; s=arc-20160816;
        b=I/jmawWNHIlAQDgjUA86fURWwifn/Ab5Hp+MeNznXpf938bIS/5oL+3FIw24hH/FYO
         y32QcnFuIBC/kRysIAbLawi2+b2T4yZSlB96R//HvuqiY+EgsW79onQglzzzmSTrosEd
         DiQyp6eHbLj3FU3CIgwZWfG0kO16PwxDJ7wkV19VCz5+R2zxMshTiUP8rCSFNyJE8MPC
         5DmeS+Fml6IrDer/z0LrOa9WrpAYjxkClsVFAC3EbXRz4PlRiYqNyZFtO9QlgZi7dbuj
         mEbEPNqkOyh7GDvYGI2PAZnZ6BObtr+I1C4eJzYQXfPSJa3f/7lCcyq/sUvfe1VlF3e1
         HP/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5YY/Z6WD5GCTh40GRusn11FiGIKlWnJ9nbkQK6HHmW4=;
        b=v4k3khpOcVykZ3SnEjcQ7b2PrA9YJfaKhPgv9OREMh7yCSJVDmw1bzPYPIH5Rde2MC
         wHYT8aGTITt6ozldRumZfvTjcTTWughNq39vUHblgMY9KLxOd4aU/kd0LleVpZEA5M04
         DJVaBmoFyKqjTL2Xvoe35NrdB27xUOFhEUzf7vMlD+JZQSQtOwfZbGNiqGwBuzTqOQEn
         Wolcgd/OdlNQbkfz2Cbh83r32CYikbVYEGQ3g+uUNNG3ElNNhFA8wbaCNSKIk7qvmoRg
         DyCAkFrafB/H+N9vDbM9eSzq9AQE0KNepaZO5ABND00SOVLbls+6WHSvXAnjXTA9mvzP
         bgrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=inIW1Yol;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e127sor75844782jab.3.2019.01.02.03.54.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 03:54:14 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=inIW1Yol;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5YY/Z6WD5GCTh40GRusn11FiGIKlWnJ9nbkQK6HHmW4=;
        b=inIW1YolOifB0wZNpsj1XRh/WYPJy6S0qzXhlgXWHBoUVSKnRC/vKw8MBClEdXTPIq
         d1ScujQs8nD7TjNELqyHzV2xArGBiO2dSHGgT/OhNupQaliUTRQ2dQBZOxC25muxM7Ky
         3yTV/lsoXtUA1oBbPF3y97fkUnQrTiCG3fiFVFUN7etYwXoKgSXEwNVwYWK8yiXLJaxl
         maRExr8VeVGZedhpbde3I2WhO5GAVz6nIf4qNgWrjdPiwRsVLcmYeGbvaWop1v4KOEUR
         g1WL7RZC40/B5fbHCVuY6lYIO7sXuxFJzUScf6q3ULoWmGRvdiIj5TWdv2W+Gk96C5nS
         2HGg==
X-Google-Smtp-Source: AFSGD/WfhHvymwlmW2vNptrlSlryxwUk+UcUmwlBx8zo+jcQ0A/u2Gn41tXSz6Wv8gadZA2Hkgr7PbEzM94U2/YkQhA=
X-Received: by 2002:a02:8904:: with SMTP id o4mr28098762jaj.35.1546430054098;
 Wed, 02 Jan 2019 03:54:14 -0800 (PST)
MIME-Version: 1.0
References: <0000000000000f35c6057e780d36@google.com>
In-Reply-To: <0000000000000f35c6057e780d36@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 2 Jan 2019 12:54:03 +0100
Message-ID:
 <CACT4Y+ZECp8Ymq=0QUNfwmfpQvWkBpoMgyUCuz0M=peehEeCHw@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in setup_kmem_cache_node
To: syzbot <syzbot+d6ed4ec679652b4fd4e4@syzkaller.appspotmail.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, David Miller <davem@davemloft.net>, 
	Eric Van Hensbergen <ericvh@gmail.com>, LKML <linux-kernel@vger.kernel.org>, 
	Latchesar Ionkov <lucho@ionkov.net>, netdev <netdev@vger.kernel.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, v9fs-developer@lists.sourceforge.net, 
	Linux-MM <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102115403.LKMz30pOYnED0P0nlJm5PApCP_6I1uZYEb8G1l-7WBk@z>

On Wed, Jan 2, 2019 at 12:36 PM syzbot
<syzbot+d6ed4ec679652b4fd4e4@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    903b77c63167 Merge tag 'linux-kselftest-4.21-rc1' of git:/..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=133428e3400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=53a2f2aa0b1f7606
> dashboard link: https://syzkaller.appspot.com/bug?extid=d6ed4ec679652b4fd4e4
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+d6ed4ec679652b4fd4e4@syzkaller.appspotmail.com

+mm maintianers

Am I missing something or __alloc_alien_cache misses check for
kmalloc_node result?

static struct alien_cache *__alloc_alien_cache(int node, int entries,
                                                int batch, gfp_t gfp)
{
        size_t memsize = sizeof(void *) * entries + sizeof(struct alien_cache);
        struct alien_cache *alc = NULL;

        alc = kmalloc_node(memsize, gfp, node);
        init_arraycache(&alc->ac, entries, batch);
        spin_lock_init(&alc->lock);
        return alc;
}


> BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
> #PF error: [WRITE]
> PGD 8b2a5067 P4D 8b2a5067 PUD a53ed067 PMD 0
> Oops: 0002 [#1] PREEMPT SMP KASAN
> CPU: 1 PID: 16188 Comm: syz-executor4 Not tainted 4.20.0+ #174
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:init_arraycache mm/slab.c:562 [inline]
> RIP: 0010:__alloc_alien_cache mm/slab.c:669 [inline]
> RIP: 0010:alloc_alien_cache mm/slab.c:689 [inline]
> RIP: 0010:setup_kmem_cache_node+0x1ed/0x400 mm/slab.c:910
> Code: 63 48 63 c3 48 0f a3 05 59 9c 72 08 73 56 8b 75 b8 4d 8d 2c c6 44 89
> e2 48 8b 7d a8 e8 fc e9 ff ff 48 83 f8 c8 49 89 c7 74 17 <c7> 40 38 00 00
> 00 00 8b 45 b0 41 89 47 3c b8 0d f0 ad ba 49 89 47
> RSP: 0018:ffff88804e827318 EFLAGS: 00010213
> RAX: 0000000000000000 RBX: 0000000000000001 RCX: 00000000006000c0
> RDX: 00000000000000a8 RSI: 0000000000000000 RDI: ffff88812c3f0040
> RBP: ffff88804e827378 R08: ffff888054cc86c0 R09: ffffed1015ce5b8f
> R10: ffffed1015ce5b8f R11: ffff8880ae72dc7b R12: 0000000000000000
> R13: ffff888095642648 R14: ffff888095642640 R15: 0000000000000000
> FS:  00007f6fef838700(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000038 CR3: 000000005034d000 CR4: 00000000001406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>   setup_kmem_cache_nodes mm/slab.c:3819 [inline]
>   __do_tune_cpucache+0x165/0x220 mm/slab.c:3889
>   do_tune_cpucache+0x25/0xd0 mm/slab.c:3898
>   enable_cpucache+0x3e/0xd0 mm/slab.c:3979
>   setup_cpu_cache+0xd4/0x1e0 mm/slab.c:1821
>   __kmem_cache_create+0x191/0x230 mm/slab.c:2134
>   create_cache+0xcd/0x1f0 mm/slab_common.c:391
>   kmem_cache_create_usercopy+0x18a/0x240 mm/slab_common.c:487
>   p9_client_create+0x986/0x1674 net/9p/client.c:1054
>   v9fs_session_init+0x217/0x1bb0 fs/9p/v9fs.c:421
>   v9fs_mount+0x7c/0x8f0 fs/9p/vfs_super.c:135
>   mount_fs+0xae/0x31d fs/super.c:1261
> kobject: 'loop1' (000000003afcedd0): kobject_uevent_env
>   vfs_kern_mount.part.35+0xdc/0x4f0 fs/namespace.c:961
> kobject: 'loop1' (000000003afcedd0): fill_kobj_path: path
> = '/devices/virtual/block/loop1'
>   vfs_kern_mount fs/namespace.c:951 [inline]
>   do_new_mount fs/namespace.c:2469 [inline]
>   do_mount+0x581/0x31f0 fs/namespace.c:2801
> kobject: 'loop2' (00000000108c69f3): kobject_uevent_env
> kobject: 'loop2' (00000000108c69f3): fill_kobj_path: path
> = '/devices/virtual/block/loop2'
>   ksys_mount+0x12d/0x140 fs/namespace.c:3017
>   __do_sys_mount fs/namespace.c:3031 [inline]
>   __se_sys_mount fs/namespace.c:3028 [inline]
>   __x64_sys_mount+0xbe/0x150 fs/namespace.c:3028
>   do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x4579b9
> Code: fd b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7
> 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff
> ff 0f 83 cb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:00007f6fef837c78 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
> RAX: ffffffffffffffda RBX: 00007f6fef837c90 RCX: 00000000004579b9
> RDX: 0000000020000000 RSI: 00000000200000c0 RDI: 0000000000000000
> RBP: 000000000073bf00 R08: 0000000020000240 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 00007f6fef8386d4
> R13: 00000000004c369b R14: 00000000004d61f8 R15: 0000000000000005
> Modules linked in:
> CR2: 0000000000000038
> ---[ end trace c630b12329ae5f74 ]---
> RIP: 0010:init_arraycache mm/slab.c:562 [inline]
> RIP: 0010:__alloc_alien_cache mm/slab.c:669 [inline]
> RIP: 0010:alloc_alien_cache mm/slab.c:689 [inline]
> RIP: 0010:setup_kmem_cache_node+0x1ed/0x400 mm/slab.c:910
> kobject: 'loop3' (00000000e06f18ba): kobject_uevent_env
> Code: 63 48 63 c3 48 0f a3 05 59 9c 72 08 73 56 8b 75 b8 4d 8d 2c c6 44 89
> e2 48 8b 7d a8 e8 fc e9 ff ff 48 83 f8 c8 49 89 c7 74 17 <c7> 40 38 00 00
> 00 00 8b 45 b0 41 89 47 3c b8 0d f0 ad ba 49 89 47
> kobject: 'loop3' (00000000e06f18ba): fill_kobj_path: path
> = '/devices/virtual/block/loop3'
> RSP: 0018:ffff88804e827318 EFLAGS: 00010213
> kobject: 'loop5' (00000000bc6ae381): kobject_uevent_env
> RAX: 0000000000000000 RBX: 0000000000000001 RCX: 00000000006000c0
> kobject: 'loop5' (00000000bc6ae381): fill_kobj_path: path
> = '/devices/virtual/block/loop5'
> RDX: 00000000000000a8 RSI: 0000000000000000 RDI: ffff88812c3f0040
> kobject: 'loop3' (00000000e06f18ba): kobject_uevent_env
> kobject: 'loop3' (00000000e06f18ba): fill_kobj_path: path
> = '/devices/virtual/block/loop3'
> RBP: ffff88804e827378 R08: ffff888054cc86c0 R09: ffffed1015ce5b8f
> kobject: 'loop1' (000000003afcedd0): kobject_uevent_env
> R10: ffffed1015ce5b8f R11: ffff8880ae72dc7b R12: 0000000000000000
> kobject: 'loop1' (000000003afcedd0): fill_kobj_path: path
> = '/devices/virtual/block/loop1'
> R13: ffff888095642648 R14: ffff888095642640 R15: 0000000000000000
> FS:  00007f6fef838700(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000400200 CR3: 000000005034d000 CR4: 00000000001406f0
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
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/0000000000000f35c6057e780d36%40google.com.
> For more options, visit https://groups.google.com/d/optout.

