Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEAECC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 15:36:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79FA02082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 15:36:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="puaNpUsl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79FA02082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 131B16B000C; Tue,  2 Apr 2019 11:36:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E04A6B000D; Tue,  2 Apr 2019 11:36:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F11376B0010; Tue,  2 Apr 2019 11:36:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBC506B000C
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 11:36:32 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id d63so5099233oig.0
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 08:36:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=59MskpIDonqhgYDOsVStI1R1nWGBhnyi1JJ5c2k/5W8=;
        b=iPbxS/7buTwmy6Px8Q7b6X0xHiK1aEoV7+y2jFMiAxcdvwqxNYCgR89Y+VPo9uJ+4R
         6lnsHzdElVL8guxsXWctl1gP+2QNud1Z0S1rTkTyrJ9KplEvbACVEPwBcRBvtWc4enGX
         5l9ppCncTjuBCZaJ8MRSKqrlxhGvdqkcNEx6A76WDZXNKuET7dM3iHxQX+WRxxXJQRko
         wsZzwg3laaKrOKlQSyE86Mc9YFcLYS8jNHnQtNb6FKetRTNUp0HeUm1BxjBjpOxsodZQ
         MrYEDH5n47G6dd/o/J3AzunioyUqykx4mDUg+8NmYGhSSV9RAenMf3RJLRFvB8lKQsjW
         ULMg==
X-Gm-Message-State: APjAAAVy9/YgxQLI4KkzKz65k7R9ZVwrUJjUBXjhfUHmbtATjN1fQiAr
	R3Q4bdhquTRzQpNe0bnSCoEVmwTFnygR2Cf5TAGO01cg8SsiGWt/I2kOzIDHhXw5dpVBTfAUGM5
	HUtLT1sFZ8dRM7bl3oeTVK+2TEhrX84Kp63UNcJmgLuXBcqpRnqQT6PC34noOacjvAQ==
X-Received: by 2002:aca:43d5:: with SMTP id q204mr12617360oia.13.1554219392221;
        Tue, 02 Apr 2019 08:36:32 -0700 (PDT)
X-Received: by 2002:aca:43d5:: with SMTP id q204mr12617272oia.13.1554219391086;
        Tue, 02 Apr 2019 08:36:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554219391; cv=none;
        d=google.com; s=arc-20160816;
        b=YTt5z+OKb4hzRWgzUN7+94dyrqvAgA+GF6BAn0BnSB/1PaxyVJppIER8DmAyw996Ua
         IYT8l/vWZjj+r84LKq6Qg8ntxK5iCvL8RicGOY9oL90THzo1TycsdhA6Xh2ukJDz33ax
         HOicBUV1O4vhPua/EaEC0ZPCg9S5cZynkdTbitY5mLjXrOkemBkmUg+oNQFCTUh++jfL
         lIahNL4hgFhY130QGRkKiGa3lDAwKAeZURZOwQ1eexSO0AX4yJ/du2jinvNf0/QcjmG+
         SvIvyn1AdibhmEDc/DHfhFdRBarJfyXX+2rBYmpJ+Vn+rItgzPSEriDG+oS3hwOKH1Sq
         N7Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=59MskpIDonqhgYDOsVStI1R1nWGBhnyi1JJ5c2k/5W8=;
        b=B5zhfXJX8qCjitIU3QBaT3u1FISb11gMZ86ZK4XKJYa6ls527iiZ+jgYK5qlkeECFz
         hPLrxQ1WNVQtU/Yz6BwF4RiROh/dREaPu+mUNTAXOw2moyC/2npboLoDW9uOtTpW9Iwa
         zo9uU9K6XgQaU7ALWLeAbAYk26WYA10oIv5BxPMNNH+Fo3278zBKAdTrnXpOFQgdraEq
         Z13V/HXa+l9y0jgUJJS3wLF4NUI3bhD9A1hw72HHqIlYJVTS6IZ8KOeoIoJNrumi83Ia
         TvBnWqn2sLS3CU+ZEjlAaBbm95l1wiZs1oqXpCBZ9RMOGbzmvYbRTV3SUBt6My6xw5zU
         Iluw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=puaNpUsl;
       spf=pass (google.com: domain of nikitasangelinas@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nikitasangelinas@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14sor8689126otm.180.2019.04.02.08.36.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 08:36:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of nikitasangelinas@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=puaNpUsl;
       spf=pass (google.com: domain of nikitasangelinas@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nikitasangelinas@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=59MskpIDonqhgYDOsVStI1R1nWGBhnyi1JJ5c2k/5W8=;
        b=puaNpUslR8zgD2yNE/Ph5dAy9UZggnvzbzrZ2mpO+hQtCq1WCCafhQ+XhiTi/oTHN8
         07071EXjmBQ4ts6jHEjpM+VGzuypIP5JMa4XNahZyrU0D0N69qya7xBGSxJD+hnU82Dv
         Vjet2nwoOnPS68OwBCtb3CgNdtcSXGCnXy2lAUZ/4mjsDQhMUeOjbXnIK395FxpWWGeV
         fNjdv9j8SDvtZUpqftsYRVEIAsRPpbL1WX8Y+PO18/hXygpsXO+ii2xcPVCIrneAE1lk
         +O7RkzH6+hi3LutTkzvvUaQCa8RmSMxyzZe/JkSvVkbiVxrfoZuR5PLOaL2ixZYZ5/B8
         ANOg==
X-Google-Smtp-Source: APXvYqxVJPUWpzPSfuohArvJBjNIBVQnc6gxMK2OtfbjjYeke6TCUEMVWfhCtphjWi6DUbwPCNj19caFeB5BM6WPvfY=
X-Received: by 2002:a9d:560b:: with SMTP id e11mr30168008oti.60.1554219390595;
 Tue, 02 Apr 2019 08:36:30 -0700 (PDT)
MIME-Version: 1.0
References: <5ca377a6.5zcN4o4WezY4tfcr%lkp@intel.com> <86f16af9-961f-5057-6596-c95c0316f7da@codeaurora.org>
In-Reply-To: <86f16af9-961f-5057-6596-c95c0316f7da@codeaurora.org>
From: Nikitas Angelinas <nikitasangelinas@gmail.com>
Date: Tue, 2 Apr 2019 08:36:22 -0700
Message-ID: <CAOHRXLZhfhWNP_=ZHJoVEzC5xE_eSK8LAj0YfDDiu+EzT=OWWQ@mail.gmail.com>
Subject: Re: b050de0f98 ("fs/binfmt_elf.c: free PT_INTERP filename ASAP"):
 BUG: KASAN: null-ptr-deref in allow_write_access
To: Mukesh Ojha <mojha@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel test robot <lkp@intel.com>, Alexey Dobriyan <adobriyan@gmail.com>, LKP <lkp@01.org>, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: multipart/alternative; boundary="000000000000adf59205858de677"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000adf59205858de677
Content-Type: text/plain; charset="UTF-8"

Hi,

Yes, it should.

Andrew seems to have added the patch to the -mm tree.



Cheers,
Nikitas

On Tue, Apr 2, 2019 at 8:23 AM Mukesh Ojha <mojha@codeaurora.org> wrote:

> I think, this may fix the problem.
>
> https://patchwork.kernel.org/patch/10878501/
>
>
> Thanks,
> Mukesh
>
> On 4/2/2019 8:24 PM, kernel test robot wrote:
> > Greetings,
> >
> > 0day kernel testing robot got the below dmesg and the first bad commit is
> >
> > https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> master
> >
> > commit b050de0f986606011986698de504c0dbc12c40dc
> > Author:     Alexey Dobriyan <adobriyan@gmail.com>
> > AuthorDate: Fri Mar 29 10:02:05 2019 +1100
> > Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> > CommitDate: Sat Mar 30 16:09:51 2019 +1100
> >
> >      fs/binfmt_elf.c: free PT_INTERP filename ASAP
> >
> >      There is no reason for PT_INTERP filename to linger till the end of
> >      the whole loading process.
> >
> >      Link: http://lkml.kernel.org/r/20190314204953.GD18143@avx2
> >      Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> >      Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> >      Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >      Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> >
> > 46238614d8  fs/binfmt_elf.c: make scope of "pos" variable smaller
> > b050de0f98  fs/binfmt_elf.c: free PT_INTERP filename ASAP
> > 05d08e2995  Add linux-next specific files for 20190402
> >
> +---------------------------------------------------------------+------------+------------+---------------+
> > |                                                               |
> 46238614d8 | b050de0f98 | next-20190402 |
> >
> +---------------------------------------------------------------+------------+------------+---------------+
> > | boot_successes                                                | 7
>     | 0          | 0             |
> > | boot_failures                                                 | 10
>      | 12         | 13            |
> > | invoked_oom-killer:gfp_mask=0x                                | 2
>     |            |               |
> > | Mem-Info                                                      | 2
>     |            |               |
> > | BUG:KASAN:slab-out-of-bounds_in_d                             | 1
>     |            |               |
> > | PANIC:double_fault                                            | 1
>     |            |               |
> > | WARNING:stack_going_in_the_wrong_direction?ip=double_fault/0x | 1
>     |            |               |
> > | RIP:lockdep_hardirqs_off                                      | 1
>     |            |               |
> > | Kernel_panic-not_syncing:Machine_halted                       | 1
>     |            |               |
> > | RIP:perf_trace_x86_exceptions                                 | 1
>     |            |               |
> > | BUG:soft_lockup-CPU##stuck_for#s                              | 7
>     | 6          | 3             |
> > | RIP:__slab_alloc                                              | 3
>     | 0          | 1             |
> > | Kernel_panic-not_syncing:softlockup:hung_tasks                | 7
>     | 6          | 3             |
> > | RIP:_raw_spin_unlock_irqrestore                               | 3
>     | 1          |               |
> > | RIP:__asan_load8                                              | 1
>     | 3          |               |
> > | RIP:copy_user_generic_unrolled                                | 1
>     |            |               |
> > | Out_of_memory_and_no_killable_processes                       | 1
>     |            |               |
> > | Kernel_panic-not_syncing:System_is_deadlocked_on_memory       | 1
>     |            |               |
> > | BUG:KASAN:null-ptr-deref_in_a                                 | 0
>     | 6          | 10            |
> > | BUG:unable_to_handle_kernel                                   | 0
>     | 6          | 10            |
> > | Oops:#[##]                                                    | 0
>     | 6          | 10            |
> > | RIP:allow_write_access                                        | 0
>     | 6          | 10            |
> > | Kernel_panic-not_syncing:Fatal_exception                      | 0
>     | 6          | 10            |
> > | RIP:__orc_find                                                | 0
>     | 1          | 1             |
> > | RIP:arch_local_irq_save                                       | 0
>     | 1          |               |
> > | RIP:__asan_load1                                              | 0
>     | 0          | 1             |
> >
> +---------------------------------------------------------------+------------+------------+---------------+
> >
> > /etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
> > Starting udev
> > [   43.717047] gfs2: path_lookup on rootfs returned error -2
> > Kernel tests: Boot OK!
> > [   45.270185]
> ==================================================================
> > [   45.277229] BUG: KASAN: null-ptr-deref in allow_write_access+0x12/0x30
> > [   45.281161] Read of size 8 at addr 000000000000001e by task
> 90-trinity/625
> > [   45.284197]
> > [   45.285252] CPU: 0 PID: 625 Comm: 90-trinity Not tainted
> 5.1.0-rc2-00406-gb050de0 #1
> > [   45.287960] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.10.2-1 04/01/2014
> > [   45.288419] BUG: unable to handle kernel NULL pointer dereference at
> 000000000000001e
> > [   45.297363] Call Trace:
> > [   45.297376]  dump_stack+0x74/0xb0
> > [   45.300404] #PF error: [normal kernel read fault]
> > [   45.301648]  ? allow_write_access+0x12/0x30
> > [   45.303103] PGD 800000000af92067 P4D 800000000af92067 PUD 9870067 PMD
> 0
> > [   45.303117] Oops: 0000 [#1] SMP KASAN PTI
> > [   45.303124] CPU: 1 PID: 626 Comm: 90-trinity Not tainted
> 5.1.0-rc2-00406-gb050de0 #1
> > [   45.303128] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.10.2-1 04/01/2014
> > [   45.303137] RIP: 0010:allow_write_access+0x12/0x30
> > [   45.303145] Code: 01 c5 31 c0 48 89 ef f3 ab 48 83 c4 60 89 d0 5b 5d
> 41 5c 41 5d 41 5e c3 48 85 ff 74 2a 53 48 89 fb 48 8d 7f 20 e8 7d 89 f6 ff
> <48> 8b 5b 20 be 04 00 00 00 48 8d bb d0 01 00 00 e8 00 6e f6 ff f0
> > [   45.303149] RSP: 0000:ffff888009ad7c68 EFLAGS: 00010247
> > [   45.303155] RAX: 0000000000000001 RBX: fffffffffffffffe RCX:
> ffffffff81307b8f
> > [   45.303158] RDX: 0000000000000000 RSI: 0000000000000008 RDI:
> 000000000000001e
> > [   45.303162] RBP: ffff88800a1410a3 R08: 0000000000000007 R09:
> 0000000000000007
> > [   45.303167] R10: ffffed1001d656f7 R11: 0000000000000000 R12:
> 0000000000000000
> > [   45.303171] R13: ffff88800a141088 R14: ffff88800de7d140 R15:
> ffff88800b2352c8
> > [   45.303177] FS:  00007f4f532d6700(0000) GS:ffff88800eb00000(0000)
> knlGS:0000000000000000
> > [   45.303181] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [   45.303185] CR2: 000000000000001e CR3: 000000000a030004 CR4:
> 00000000003606e0
> > [   45.303191] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> > [   45.303195] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
> 0000000000000400
> > [   45.303198] Call Trace:
> > [   45.303208]  load_elf_binary+0x1548/0x15ae
> > [   45.303215]  ? load_misc_binary+0x2aa/0x68c
> > [   45.303223]  ? mark_held_locks+0x83/0x83
> > [   45.303230]  ? match_held_lock+0x18/0xf8
> > [   45.303237]  ? set_fs+0x29/0x29
> > [   45.303246]  ? cpumask_test_cpu+0x28/0x28
> > [   45.303255]  search_binary_handler+0xa2/0x20d
> > [   45.303263]  __do_execve_file+0xa3d/0xe66
> > [   45.303270]  ? open_exec+0x34/0x34
> > [   45.303277]  ? strncpy_from_user+0xd9/0x18c
> > [   45.303284]  do_execve+0x1c/0x1f
> > [   45.303291]  __x64_sys_execve+0x41/0x48
> > [   45.303299]  do_syscall_64+0x69/0x85
> > [   45.303308]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > [   45.303314] RIP: 0033:0x7f4f52ddb807
> > [   45.303321] Code: 77 19 f4 48 89 d7 44 89 c0 0f 05 48 3d 00 f0 ff ff
> 76 e0 f7 d8 64 41 89 01 eb d8 f7 d8 64 41 89 01 eb df b8 3b 00 00 00 0f 05
> <48> 3d 00 f0 ff ff 77 02 f3 c3 48 8b 15 00 a6 2d 00 f7 d8 64 89 02
> > [   45.303324] RSP: 002b:00007ffc2f1cae88 EFLAGS: 00000206 ORIG_RAX:
> 000000000000003b
> > [   45.303331] RAX: ffffffffffffffda RBX: 00000000006925d8 RCX:
> 00007f4f52ddb807
> > [   45.303335] RDX: 0000000000692620 RSI: 00000000006925d8 RDI:
> 00000000006914d8
> > [   45.303339] RBP: 0000000000691010 R08: 00000000006914d0 R09:
> 0101010101010101
> > [   45.303343] R10: 00007ffc2f1cac10 R11: 0000000000000206 R12:
> 00000000006914d8
> > [   45.303347] R13: 0000000000692620 R14: 0000000000692620 R15:
> 00007ffc2f1ccf60
> > [   45.303351] Modules linked in:
> > [   45.303357] CR2: 000000000000001e
> > [   45.303367] ---[ end trace bbce985a62ebde0d ]---
> > [   45.303373] RIP: 0010:allow_write_access+0x12/0x30
> >
> >                                                            # HH:MM
> RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
> > git bisect start 05d08e2995cbe6efdb993482ee0d38a77040861a
> 79a3aaa7b82e3106be97842dedfd8429248896e6 --
> > git bisect good 2dbd2d8f2c2ccd640f9cb6462e23f0a5ac67e1a2  # 18:33  G
>  11     0   11  11  Merge remote-tracking branch 'net-next/master'
> > git bisect good d177ed11c13c43e0f5a289727c0237b9141ca458  # 18:45  G
>  12     0   11  11  Merge remote-tracking branch 'kvm-arm/next'
> > git bisect good a1a606c7831374d6ef20ed04c16a76b44f79bcab  # 18:58  G
>  12     0   11  11  Merge remote-tracking branch 'rpmsg/for-next'
> > git bisect good f2ea30d060707080d2d5f8532f0efebfa3a04302  # 19:21  G
>  12     0   11  11  Merge remote-tracking branch 'nvdimm/libnvdimm-for-next'
> > git bisect good e006c7613228cfa7abefd1c5175e171e6ae2c4b7  # 19:34  G
>  12     0   11  11  Merge remote-tracking branch 'xarray/xarray'
> > git bisect good 046b78627faba9a4b85c9f7a0bba764bbbbe76ff  # 19:49  G
>  12     0   12  12  Merge remote-tracking branch 'devfreq/for-next'
> > git bisect  bad 1999d633921bdbbf76c7f1065d15ec237a977c02  # 20:05  B
>   0     9   24   0  Merge branch 'akpm-current/current'
> > git bisect good 4aa445a97c1da9d169f63377262709254e496f65  # 20:18  G
>  11     0   10  10  mm: introduce put_user_page*(), placeholder versions
> > git bisect good f6e06951c4f5f330471530bd12a2b75ed5326005  # 20:37  G
>  11     0   11  11  lib/plist: rename DEBUG_PI_LIST to DEBUG_PLIST
> > git bisect  bad ffbb2d4bbda0f0e82531b4a839cee3e6db0eb09f  # 20:52  B
>   1     6    1   1  autofs: fix some word usage oddities in autofs.txt
> > git bisect good bc341e1f87c0f100165c5fd2a693d2c90477e322  # 21:21  G
>  11     0   10  10  lib/test_bitmap.c: switch test_bitmap_parselist to
> ktime_get()
> > git bisect good 11d2673e0f90086825df35385fc52d4cc9015c21  # 21:35  G
>  12     0   11  11  checkpatch: fix something
> > git bisect good 46238614d8a1a3cde66abc7fd8c4b75c9e4793f3  # 21:51  G
>  12     0   10  10  fs/binfmt_elf.c: make scope of "pos" variable smaller
> > git bisect  bad 42d4a144a5a5b05b981beb57b5f0891b2eb85b78  # 22:04  B
>   0    10   25   0  fs/binfmt_elf.c: delete trailing "return;" in functions
> returning "void"
> > git bisect  bad b050de0f986606011986698de504c0dbc12c40dc  # 22:21  B
>   0     1   16   0  fs/binfmt_elf.c: free PT_INTERP filename ASAP
> > # first bad commit: [b050de0f986606011986698de504c0dbc12c40dc]
> fs/binfmt_elf.c: free PT_INTERP filename ASAP
> > git bisect good 46238614d8a1a3cde66abc7fd8c4b75c9e4793f3  # 22:24  G
>  34     0   27  37  fs/binfmt_elf.c: make scope of "pos" variable smaller
> > # extra tests with debug options
> > git bisect  bad b050de0f986606011986698de504c0dbc12c40dc  # 22:34  B
>   4     8    4   4  fs/binfmt_elf.c: free PT_INTERP filename ASAP
> > # extra tests on HEAD of linux-next/master
> > git bisect  bad 05d08e2995cbe6efdb993482ee0d38a77040861a  # 22:34  B
>   0    10   31   3  Add linux-next specific files for 20190402
> > # extra tests on tree/branch linux-next/master
> > git bisect  bad 05d08e2995cbe6efdb993482ee0d38a77040861a  # 22:35  B
>   0    10   31   3  Add linux-next specific files for 20190402
> > # extra tests with first bad commit reverted
> > git bisect good 150238fdb7cd7234ce95fb083866dbf5f70082c9  # 22:53  G
>  13     0   11  11  Revert "fs/binfmt_elf.c: free PT_INTERP filename ASAP"
> >
> > ---
> > 0-DAY kernel test infrastructure                Open Source Technology
> Center
> > https://lists.01.org/pipermail/lkp                          Intel
> Corporation
>
>

--000000000000adf59205858de677
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div class=3D"gmail_default" style=3D"fon=
t-family:arial,helvetica,sans-serif;font-size:small"><div class=3D"gmail_de=
fault">Hi,</div><div class=3D"gmail_default"><br></div><div class=3D"gmail_=
default">Yes, it should.</div><div class=3D"gmail_default"><br></div><div c=
lass=3D"gmail_default">Andrew seems to have added the patch to the -mm tree=
.</div><div class=3D"gmail_default"><br></div><div class=3D"gmail_default">=
<br></div><div class=3D"gmail_default"><br></div><div class=3D"gmail_defaul=
t">Cheers,</div><div class=3D"gmail_default">Nikitas</div></div></div></div=
><br><div class=3D"gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">On Tu=
e, Apr 2, 2019 at 8:23 AM Mukesh Ojha &lt;<a href=3D"mailto:mojha@codeauror=
a.org">mojha@codeaurora.org</a>&gt; wrote:<br></div><blockquote class=3D"gm=
ail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,=
204,204);padding-left:1ex">I think, this may fix the problem.<br>
<br>
<a href=3D"https://patchwork.kernel.org/patch/10878501/" rel=3D"noreferrer"=
 target=3D"_blank">https://patchwork.kernel.org/patch/10878501/</a><br>
<br>
<br>
Thanks,<br>
Mukesh<br>
<br>
On 4/2/2019 8:24 PM, kernel test robot wrote:<br>
&gt; Greetings,<br>
&gt;<br>
&gt; 0day kernel testing robot got the below dmesg and the first bad commit=
 is<br>
&gt;<br>
&gt; <a href=3D"https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-=
next.git" rel=3D"noreferrer" target=3D"_blank">https://git.kernel.org/pub/s=
cm/linux/kernel/git/next/linux-next.git</a> master<br>
&gt;<br>
&gt; commit b050de0f986606011986698de504c0dbc12c40dc<br>
&gt; Author:=C2=A0 =C2=A0 =C2=A0Alexey Dobriyan &lt;<a href=3D"mailto:adobr=
iyan@gmail.com" target=3D"_blank">adobriyan@gmail.com</a>&gt;<br>
&gt; AuthorDate: Fri Mar 29 10:02:05 2019 +1100<br>
&gt; Commit:=C2=A0 =C2=A0 =C2=A0Stephen Rothwell &lt;<a href=3D"mailto:sfr@=
canb.auug.org.au" target=3D"_blank">sfr@canb.auug.org.au</a>&gt;<br>
&gt; CommitDate: Sat Mar 30 16:09:51 2019 +1100<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 fs/binfmt_elf.c: free PT_INTERP filename ASAP<br>
&gt;=C2=A0 =C2=A0 =C2=A0 <br>
&gt;=C2=A0 =C2=A0 =C2=A0 There is no reason for PT_INTERP filename to linge=
r till the end of<br>
&gt;=C2=A0 =C2=A0 =C2=A0 the whole loading process.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 <br>
&gt;=C2=A0 =C2=A0 =C2=A0 Link: <a href=3D"http://lkml.kernel.org/r/20190314=
204953.GD18143@avx2" rel=3D"noreferrer" target=3D"_blank">http://lkml.kerne=
l.org/r/20190314204953.GD18143@avx2</a><br>
&gt;=C2=A0 =C2=A0 =C2=A0 Signed-off-by: Alexey Dobriyan &lt;<a href=3D"mail=
to:adobriyan@gmail.com" target=3D"_blank">adobriyan@gmail.com</a>&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 Reviewed-by: Andrew Morton &lt;<a href=3D"mailto:a=
kpm@linux-foundation.org" target=3D"_blank">akpm@linux-foundation.org</a>&g=
t;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 Signed-off-by: Andrew Morton &lt;<a href=3D"mailto=
:akpm@linux-foundation.org" target=3D"_blank">akpm@linux-foundation.org</a>=
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 Signed-off-by: Stephen Rothwell &lt;<a href=3D"mai=
lto:sfr@canb.auug.org.au" target=3D"_blank">sfr@canb.auug.org.au</a>&gt;<br=
>
&gt;<br>
&gt; 46238614d8=C2=A0 fs/binfmt_elf.c: make scope of &quot;pos&quot; variab=
le smaller<br>
&gt; b050de0f98=C2=A0 fs/binfmt_elf.c: free PT_INTERP filename ASAP<br>
&gt; 05d08e2995=C2=A0 Add linux-next specific files for 20190402<br>
&gt; +---------------------------------------------------------------+-----=
-------+------------+---------------+<br>
&gt; |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| 46238614d8 | b050de0f98 | next-20190402 |<br>
&gt; +---------------------------------------------------------------+-----=
-------+------------+---------------+<br>
&gt; | boot_successes=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 7=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | boot_failures=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 10=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0| 12=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 13=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 |<br>
&gt; | invoked_oom-killer:gfp_mask=3D0x=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | 2=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | Mem-Info=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 2=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | BUG:KASAN:slab-out-of-bounds_in_d=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 1=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
|=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | PANIC:double_fault=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0|<br>
&gt; | WARNING:stack_going_in_the_wrong_direction?ip=3Ddouble_fault/0x | 1=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | RIP:lockdep_hardirqs_off=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0|<br>
&gt; | Kernel_panic-not_syncing:Machine_halted=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 1=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | RIP:perf_trace_x86_exceptions=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | BUG:soft_lockup-CPU##stuck_for#s=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 7=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 6=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
3=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | RIP:__slab_alloc=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 3=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|<br>
&gt; | Kernel_panic-not_syncing:softlockup:hung_tasks=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 7=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
6=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 3=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|<br>
&gt; | RIP:_raw_spin_unlock_irqrestore=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| 3=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | RIP:__asan_load8=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
3=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0|<br>
&gt; | RIP:copy_user_generic_unrolled=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | Out_of_memory_and_no_killable_processes=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 1=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | Kernel_panic-not_syncing:System_is_deadlocked_on_memory=C2=A0 =C2=A0=
 =C2=A0 =C2=A0| 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0|<br>
&gt; | BUG:KASAN:null-ptr-deref_in_a=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 6=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | 10=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |<br>
&gt; | BUG:unable_to_handle_kernel=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0| 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 6=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 | 10=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |<br>
&gt; | Oops:#[##]=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 0=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | 6=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 10=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 |<br>
&gt; | RIP:allow_write_access=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 6=C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 | 10=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |<br>
&gt; | Kernel_panic-not_syncing:Fatal_exception=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 0=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 | 6=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 10=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 |<br>
&gt; | RIP:__orc_find=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 1=C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0|<br>
&gt; | RIP:arch_local_irq_save=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0| 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 1=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0|<br>
&gt; | RIP:__asan_load1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 1=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|<br>
&gt; +---------------------------------------------------------------+-----=
-------+------------+---------------+<br>
&gt;<br>
&gt; /etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found<br>
&gt; Starting udev<br>
&gt; [=C2=A0 =C2=A043.717047] gfs2: path_lookup on rootfs returned error -2=
<br>
&gt; Kernel tests: Boot OK!<br>
&gt; [=C2=A0 =C2=A045.270185] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D<br>
&gt; [=C2=A0 =C2=A045.277229] BUG: KASAN: null-ptr-deref in allow_write_acc=
ess+0x12/0x30<br>
&gt; [=C2=A0 =C2=A045.281161] Read of size 8 at addr 000000000000001e by ta=
sk 90-trinity/625<br>
&gt; [=C2=A0 =C2=A045.284197]<br>
&gt; [=C2=A0 =C2=A045.285252] CPU: 0 PID: 625 Comm: 90-trinity Not tainted =
5.1.0-rc2-00406-gb050de0 #1<br>
&gt; [=C2=A0 =C2=A045.287960] Hardware name: QEMU Standard PC (i440FX + PII=
X, 1996), BIOS 1.10.2-1 04/01/2014<br>
&gt; [=C2=A0 =C2=A045.288419] BUG: unable to handle kernel NULL pointer der=
eference at 000000000000001e<br>
&gt; [=C2=A0 =C2=A045.297363] Call Trace:<br>
&gt; [=C2=A0 =C2=A045.297376]=C2=A0 dump_stack+0x74/0xb0<br>
&gt; [=C2=A0 =C2=A045.300404] #PF error: [normal kernel read fault]<br>
&gt; [=C2=A0 =C2=A045.301648]=C2=A0 ? allow_write_access+0x12/0x30<br>
&gt; [=C2=A0 =C2=A045.303103] PGD 800000000af92067 P4D 800000000af92067 PUD=
 9870067 PMD 0<br>
&gt; [=C2=A0 =C2=A045.303117] Oops: 0000 [#1] SMP KASAN PTI<br>
&gt; [=C2=A0 =C2=A045.303124] CPU: 1 PID: 626 Comm: 90-trinity Not tainted =
5.1.0-rc2-00406-gb050de0 #1<br>
&gt; [=C2=A0 =C2=A045.303128] Hardware name: QEMU Standard PC (i440FX + PII=
X, 1996), BIOS 1.10.2-1 04/01/2014<br>
&gt; [=C2=A0 =C2=A045.303137] RIP: 0010:allow_write_access+0x12/0x30<br>
&gt; [=C2=A0 =C2=A045.303145] Code: 01 c5 31 c0 48 89 ef f3 ab 48 83 c4 60 =
89 d0 5b 5d 41 5c 41 5d 41 5e c3 48 85 ff 74 2a 53 48 89 fb 48 8d 7f 20 e8 =
7d 89 f6 ff &lt;48&gt; 8b 5b 20 be 04 00 00 00 48 8d bb d0 01 00 00 e8 00 6=
e f6 ff f0<br>
&gt; [=C2=A0 =C2=A045.303149] RSP: 0000:ffff888009ad7c68 EFLAGS: 00010247<b=
r>
&gt; [=C2=A0 =C2=A045.303155] RAX: 0000000000000001 RBX: fffffffffffffffe R=
CX: ffffffff81307b8f<br>
&gt; [=C2=A0 =C2=A045.303158] RDX: 0000000000000000 RSI: 0000000000000008 R=
DI: 000000000000001e<br>
&gt; [=C2=A0 =C2=A045.303162] RBP: ffff88800a1410a3 R08: 0000000000000007 R=
09: 0000000000000007<br>
&gt; [=C2=A0 =C2=A045.303167] R10: ffffed1001d656f7 R11: 0000000000000000 R=
12: 0000000000000000<br>
&gt; [=C2=A0 =C2=A045.303171] R13: ffff88800a141088 R14: ffff88800de7d140 R=
15: ffff88800b2352c8<br>
&gt; [=C2=A0 =C2=A045.303177] FS:=C2=A0 00007f4f532d6700(0000) GS:ffff88800=
eb00000(0000) knlGS:0000000000000000<br>
&gt; [=C2=A0 =C2=A045.303181] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 0000000=
080050033<br>
&gt; [=C2=A0 =C2=A045.303185] CR2: 000000000000001e CR3: 000000000a030004 C=
R4: 00000000003606e0<br>
&gt; [=C2=A0 =C2=A045.303191] DR0: 0000000000000000 DR1: 0000000000000000 D=
R2: 0000000000000000<br>
&gt; [=C2=A0 =C2=A045.303195] DR3: 0000000000000000 DR6: 00000000fffe0ff0 D=
R7: 0000000000000400<br>
&gt; [=C2=A0 =C2=A045.303198] Call Trace:<br>
&gt; [=C2=A0 =C2=A045.303208]=C2=A0 load_elf_binary+0x1548/0x15ae<br>
&gt; [=C2=A0 =C2=A045.303215]=C2=A0 ? load_misc_binary+0x2aa/0x68c<br>
&gt; [=C2=A0 =C2=A045.303223]=C2=A0 ? mark_held_locks+0x83/0x83<br>
&gt; [=C2=A0 =C2=A045.303230]=C2=A0 ? match_held_lock+0x18/0xf8<br>
&gt; [=C2=A0 =C2=A045.303237]=C2=A0 ? set_fs+0x29/0x29<br>
&gt; [=C2=A0 =C2=A045.303246]=C2=A0 ? cpumask_test_cpu+0x28/0x28<br>
&gt; [=C2=A0 =C2=A045.303255]=C2=A0 search_binary_handler+0xa2/0x20d<br>
&gt; [=C2=A0 =C2=A045.303263]=C2=A0 __do_execve_file+0xa3d/0xe66<br>
&gt; [=C2=A0 =C2=A045.303270]=C2=A0 ? open_exec+0x34/0x34<br>
&gt; [=C2=A0 =C2=A045.303277]=C2=A0 ? strncpy_from_user+0xd9/0x18c<br>
&gt; [=C2=A0 =C2=A045.303284]=C2=A0 do_execve+0x1c/0x1f<br>
&gt; [=C2=A0 =C2=A045.303291]=C2=A0 __x64_sys_execve+0x41/0x48<br>
&gt; [=C2=A0 =C2=A045.303299]=C2=A0 do_syscall_64+0x69/0x85<br>
&gt; [=C2=A0 =C2=A045.303308]=C2=A0 entry_SYSCALL_64_after_hwframe+0x49/0xb=
e<br>
&gt; [=C2=A0 =C2=A045.303314] RIP: 0033:0x7f4f52ddb807<br>
&gt; [=C2=A0 =C2=A045.303321] Code: 77 19 f4 48 89 d7 44 89 c0 0f 05 48 3d =
00 f0 ff ff 76 e0 f7 d8 64 41 89 01 eb d8 f7 d8 64 41 89 01 eb df b8 3b 00 =
00 00 0f 05 &lt;48&gt; 3d 00 f0 ff ff 77 02 f3 c3 48 8b 15 00 a6 2d 00 f7 d=
8 64 89 02<br>
&gt; [=C2=A0 =C2=A045.303324] RSP: 002b:00007ffc2f1cae88 EFLAGS: 00000206 O=
RIG_RAX: 000000000000003b<br>
&gt; [=C2=A0 =C2=A045.303331] RAX: ffffffffffffffda RBX: 00000000006925d8 R=
CX: 00007f4f52ddb807<br>
&gt; [=C2=A0 =C2=A045.303335] RDX: 0000000000692620 RSI: 00000000006925d8 R=
DI: 00000000006914d8<br>
&gt; [=C2=A0 =C2=A045.303339] RBP: 0000000000691010 R08: 00000000006914d0 R=
09: 0101010101010101<br>
&gt; [=C2=A0 =C2=A045.303343] R10: 00007ffc2f1cac10 R11: 0000000000000206 R=
12: 00000000006914d8<br>
&gt; [=C2=A0 =C2=A045.303347] R13: 0000000000692620 R14: 0000000000692620 R=
15: 00007ffc2f1ccf60<br>
&gt; [=C2=A0 =C2=A045.303351] Modules linked in:<br>
&gt; [=C2=A0 =C2=A045.303357] CR2: 000000000000001e<br>
&gt; [=C2=A0 =C2=A045.303367] ---[ end trace bbce985a62ebde0d ]---<br>
&gt; [=C2=A0 =C2=A045.303373] RIP: 0010:allow_write_access+0x12/0x30<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 # HH:MM =
RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD<br>
&gt; git bisect start 05d08e2995cbe6efdb993482ee0d38a77040861a 79a3aaa7b82e=
3106be97842dedfd8429248896e6 --<br>
&gt; git bisect good 2dbd2d8f2c2ccd640f9cb6462e23f0a5ac67e1a2=C2=A0 # 18:33=
=C2=A0 G=C2=A0 =C2=A0 =C2=A011=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A011=C2=A0 11=
=C2=A0 Merge remote-tracking branch &#39;net-next/master&#39;<br>
&gt; git bisect good d177ed11c13c43e0f5a289727c0237b9141ca458=C2=A0 # 18:45=
=C2=A0 G=C2=A0 =C2=A0 =C2=A012=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A011=C2=A0 11=
=C2=A0 Merge remote-tracking branch &#39;kvm-arm/next&#39;<br>
&gt; git bisect good a1a606c7831374d6ef20ed04c16a76b44f79bcab=C2=A0 # 18:58=
=C2=A0 G=C2=A0 =C2=A0 =C2=A012=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A011=C2=A0 11=
=C2=A0 Merge remote-tracking branch &#39;rpmsg/for-next&#39;<br>
&gt; git bisect good f2ea30d060707080d2d5f8532f0efebfa3a04302=C2=A0 # 19:21=
=C2=A0 G=C2=A0 =C2=A0 =C2=A012=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A011=C2=A0 11=
=C2=A0 Merge remote-tracking branch &#39;nvdimm/libnvdimm-for-next&#39;<br>
&gt; git bisect good e006c7613228cfa7abefd1c5175e171e6ae2c4b7=C2=A0 # 19:34=
=C2=A0 G=C2=A0 =C2=A0 =C2=A012=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A011=C2=A0 11=
=C2=A0 Merge remote-tracking branch &#39;xarray/xarray&#39;<br>
&gt; git bisect good 046b78627faba9a4b85c9f7a0bba764bbbbe76ff=C2=A0 # 19:49=
=C2=A0 G=C2=A0 =C2=A0 =C2=A012=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A012=C2=A0 12=
=C2=A0 Merge remote-tracking branch &#39;devfreq/for-next&#39;<br>
&gt; git bisect=C2=A0 bad 1999d633921bdbbf76c7f1065d15ec237a977c02=C2=A0 # =
20:05=C2=A0 B=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=A09=C2=A0 =C2=A024=C2=
=A0 =C2=A00=C2=A0 Merge branch &#39;akpm-current/current&#39;<br>
&gt; git bisect good 4aa445a97c1da9d169f63377262709254e496f65=C2=A0 # 20:18=
=C2=A0 G=C2=A0 =C2=A0 =C2=A011=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A010=C2=A0 10=
=C2=A0 mm: introduce put_user_page*(), placeholder versions<br>
&gt; git bisect good f6e06951c4f5f330471530bd12a2b75ed5326005=C2=A0 # 20:37=
=C2=A0 G=C2=A0 =C2=A0 =C2=A011=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A011=C2=A0 11=
=C2=A0 lib/plist: rename DEBUG_PI_LIST to DEBUG_PLIST<br>
&gt; git bisect=C2=A0 bad ffbb2d4bbda0f0e82531b4a839cee3e6db0eb09f=C2=A0 # =
20:52=C2=A0 B=C2=A0 =C2=A0 =C2=A0 1=C2=A0 =C2=A0 =C2=A06=C2=A0 =C2=A0 1=C2=
=A0 =C2=A01=C2=A0 autofs: fix some word usage oddities in autofs.txt<br>
&gt; git bisect good bc341e1f87c0f100165c5fd2a693d2c90477e322=C2=A0 # 21:21=
=C2=A0 G=C2=A0 =C2=A0 =C2=A011=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A010=C2=A0 10=
=C2=A0 lib/test_bitmap.c: switch test_bitmap_parselist to ktime_get()<br>
&gt; git bisect good 11d2673e0f90086825df35385fc52d4cc9015c21=C2=A0 # 21:35=
=C2=A0 G=C2=A0 =C2=A0 =C2=A012=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A011=C2=A0 11=
=C2=A0 checkpatch: fix something<br>
&gt; git bisect good 46238614d8a1a3cde66abc7fd8c4b75c9e4793f3=C2=A0 # 21:51=
=C2=A0 G=C2=A0 =C2=A0 =C2=A012=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A010=C2=A0 10=
=C2=A0 fs/binfmt_elf.c: make scope of &quot;pos&quot; variable smaller<br>
&gt; git bisect=C2=A0 bad 42d4a144a5a5b05b981beb57b5f0891b2eb85b78=C2=A0 # =
22:04=C2=A0 B=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 10=C2=A0 =C2=A025=C2=A0 =
=C2=A00=C2=A0 fs/binfmt_elf.c: delete trailing &quot;return;&quot; in funct=
ions returning &quot;void&quot;<br>
&gt; git bisect=C2=A0 bad b050de0f986606011986698de504c0dbc12c40dc=C2=A0 # =
22:21=C2=A0 B=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 =C2=A01=C2=A0 =C2=A016=C2=
=A0 =C2=A00=C2=A0 fs/binfmt_elf.c: free PT_INTERP filename ASAP<br>
&gt; # first bad commit: [b050de0f986606011986698de504c0dbc12c40dc] fs/binf=
mt_elf.c: free PT_INTERP filename ASAP<br>
&gt; git bisect good 46238614d8a1a3cde66abc7fd8c4b75c9e4793f3=C2=A0 # 22:24=
=C2=A0 G=C2=A0 =C2=A0 =C2=A034=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A027=C2=A0 37=
=C2=A0 fs/binfmt_elf.c: make scope of &quot;pos&quot; variable smaller<br>
&gt; # extra tests with debug options<br>
&gt; git bisect=C2=A0 bad b050de0f986606011986698de504c0dbc12c40dc=C2=A0 # =
22:34=C2=A0 B=C2=A0 =C2=A0 =C2=A0 4=C2=A0 =C2=A0 =C2=A08=C2=A0 =C2=A0 4=C2=
=A0 =C2=A04=C2=A0 fs/binfmt_elf.c: free PT_INTERP filename ASAP<br>
&gt; # extra tests on HEAD of linux-next/master<br>
&gt; git bisect=C2=A0 bad 05d08e2995cbe6efdb993482ee0d38a77040861a=C2=A0 # =
22:34=C2=A0 B=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 10=C2=A0 =C2=A031=C2=A0 =
=C2=A03=C2=A0 Add linux-next specific files for 20190402<br>
&gt; # extra tests on tree/branch linux-next/master<br>
&gt; git bisect=C2=A0 bad 05d08e2995cbe6efdb993482ee0d38a77040861a=C2=A0 # =
22:35=C2=A0 B=C2=A0 =C2=A0 =C2=A0 0=C2=A0 =C2=A0 10=C2=A0 =C2=A031=C2=A0 =
=C2=A03=C2=A0 Add linux-next specific files for 20190402<br>
&gt; # extra tests with first bad commit reverted<br>
&gt; git bisect good 150238fdb7cd7234ce95fb083866dbf5f70082c9=C2=A0 # 22:53=
=C2=A0 G=C2=A0 =C2=A0 =C2=A013=C2=A0 =C2=A0 =C2=A00=C2=A0 =C2=A011=C2=A0 11=
=C2=A0 Revert &quot;fs/binfmt_elf.c: free PT_INTERP filename ASAP&quot;<br>
&gt;<br>
&gt; ---<br>
&gt; 0-DAY kernel test infrastructure=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 Open Source Technology Center<br>
&gt; <a href=3D"https://lists.01.org/pipermail/lkp" rel=3D"noreferrer" targ=
et=3D"_blank">https://lists.01.org/pipermail/lkp</a>=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Intel=
 Corporation<br>
<br>
</blockquote></div>

--000000000000adf59205858de677--

