Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.2 required=3.0 tests=CHARSET_FARAWAY_HEADER,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B280EC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 03:37:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AD6520815
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 03:37:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AD6520815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A41C8E0002; Thu, 31 Jan 2019 22:37:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12D158E0001; Thu, 31 Jan 2019 22:37:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0EA28E0002; Thu, 31 Jan 2019 22:37:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A9C708E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 22:37:22 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a23so4395102pfo.2
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 19:37:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:mime-version:date:content-transfer-encoding;
        bh=7MPso2jC/HsMQdLfLdSPdhkDfsWNlzCkF19ByQTLSWs=;
        b=MW4YrQ0j2JnKVu7M98h08ylgoJ6HphsDlO0uDoXV205UQ9kQoYMOi89YYbYE1fIkzA
         6BVESJtmWMy9Md31yWeUoSaD6yutWneM7nS2RkgxaKWpcW8GE0tyGlIU1D+dmDbvy77g
         PIVcI2CtXpb4sxzisHsB9elbJgHnTWAqqzrGo6wvo0m+U2LFnb/cakjPDFF431mATXCI
         Gy9HAMAW1Y2sd0qBJRGb1PoJLwBooBVU3SE2BLF/ymLeBPHd5qprtabqfqwVDfx5Qfw0
         w0uXpbKz/7Af3OyzlAe0eu88hif2ooyi/t5uD6iRquX9rlw15XKD1ekbM6mZF6egbQf/
         7Wdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukduHi3L3I8L1qzOB0T5H8x7bb2f72UN7UNzNTYQEf1GbZ6m4Vdv
	YgduTbMuhBgijXagFx1iR3WJ9XG/PVwTruDlkuGprgx4wKpc5kMFdNcW333N1iXkH68CB8XuO4F
	9v7SoxS16gY8zy/fmva5Wh8A7Z4rgh6VyTCK8MkKARaNoOnj9LRppeVmT4hloHtK8qQ==
X-Received: by 2002:a63:f34b:: with SMTP id t11mr34002089pgj.341.1548992242337;
        Thu, 31 Jan 2019 19:37:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5A2CmsdQAWszF9qtB4TqV9ZEK80U8ESJqwRy1TA5xvjAWBkwKFVCH2paWUOVirIXE7EoW9
X-Received: by 2002:a63:f34b:: with SMTP id t11mr34002038pgj.341.1548992241348;
        Thu, 31 Jan 2019 19:37:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548992241; cv=none;
        d=google.com; s=arc-20160816;
        b=WTldqc8AToKXjd0NJtrAkELVczj4nKfREN2fcZhNt0HI82DVDhmFQz6XEvPiiX0qfT
         gcSPPABS/xlIninLqUK5MWaEOKh/+31Nzw98g2NnAxfo/p2BJsubgh3s/jQJqsaEQVhv
         YXJmMLrHa9PnEszR2lvC/6hDj27JVi0a/+3AX1ghjrfxb4obJhkZ5mIliHinyeq4Fmxm
         +9AK6tsxX1/DcYTE63YZOeNLhPjKy6GCzKFBGlyr8JqUIUM7hv3ESGN1pgunOef0a97J
         PmNlNEGk48VKqdJX1yb1V5AhIFbMz3F4U57yC+BSVFHmRSyg3+s28cMvKWKKEDdDTpta
         IDuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:date:mime-version:cc:to:from:subject
         :message-id;
        bh=7MPso2jC/HsMQdLfLdSPdhkDfsWNlzCkF19ByQTLSWs=;
        b=HsU6ny7/sNXPWkNM9TJCfkrgvEviPCaXFtPEhjbXlv8ccFUhu8p2Jc190AxaFyTOZE
         cB1m0wh0C9eMQupHRmQJKaCvFCBRH6jtccT+ZnXU9g18SSfgE/2FP5ThERN/1efSUX2h
         Nn+ty8MFUAKAQsiB3qF6Zm/lUwU8eD1s1cnMD51leS90nDJa020moXpLZlIc4oJjf6/O
         LsJ1zwjJ/nGdFWdgbQce5Rjc5pHyt+eX3DK5JDW+CH1JIZa4PsFQdXPjFKd1Zsva8OXj
         FmWJ2kAuglD89TpsMDXKzJhbkrcAadviONI1MqxTKBL75S8VBl3Vb99UcOCtY9kNyAeR
         aTEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n34si4481618pld.381.2019.01.31.19.37.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 19:37:21 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav403.sakura.ne.jp (fsav403.sakura.ne.jp [133.242.250.102])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x113b7Aq028197;
	Fri, 1 Feb 2019 12:37:07 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav403.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav403.sakura.ne.jp);
 Fri, 01 Feb 2019 12:37:07 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav403.sakura.ne.jp)
Received: from www262.sakura.ne.jp (localhost [127.0.0.1])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x113b7Gr028188;
	Fri, 1 Feb 2019 12:37:07 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: (from i-love@localhost)
	by www262.sakura.ne.jp (8.15.2/8.15.2/Submit) id x113b72e028186;
	Fri, 1 Feb 2019 12:37:07 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Message-Id: <201902010337.x113b72e028186@www262.sakura.ne.jp>
X-Authentication-Warning: www262.sakura.ne.jp: i-love set sender to penguin-kernel@i-love.sakura.ne.jp using -f
Subject: [linux-next-20190131] NULL pointer dereference at
 =?ISO-2022-JP?B?c2hyaW5rX25vZGVfbWVtY2cu?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: Chris Down <chris@chrisdown.name>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>,
        linux-mm@kvack.org
MIME-Version: 1.0
Date: Fri, 01 Feb 2019 12:37:07 +0900
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 8a907cdf0177ab40 ("mm, memcg: proportional memory.{low,min} reclaim")
broke global reclaim by kdump kernel due to NULL pointer dereference at

   protection = mem_cgroup_protection(memcg);

. Please fix.

----------
[    0.000000][    T0] Linux version 5.0.0-rc4-next-20190131 (root@localhost.localdomain) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-36) (GCC)) #280 SMP PREEMPT Fri Feb 1 09:11:44 JST 2019
[    0.000000][    T0] Command line: BOOT_IMAGE=/boot/vmlinuz-5.0.0-rc4-next-20190131 ro security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8 cgroup_no_v1=all irqpoll nr_cpus=1 reset_devices cgroup_disable=memory mce=off numa=off udev.children-max=2 panic=10 rootflags=nofail acpi_no_memhotplug transparent_hugepage=never nokaslr disable_cpu_apicid=0 elfcorehdr=867732K
(...snipped...)
[   28.323429][   T31] BUG: unable to handle kernel NULL pointer dereference at 0000000000000180
[   28.326592][   T31] #PF error: [normal kernel read fault]
[   28.328538][   T31] PGD 274bd067 P4D 274bd067 PUD 276e1067 PMD 0 
[   28.330587][   T31] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   28.332627][   T31] CPU: 0 PID: 31 Comm: kswapd0 Not tainted 5.0.0-rc4-next-20190131 #280
[   28.335356][   T31] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[   28.338845][   T31] RIP: 0010:shrink_node_memcg+0xa1/0x4d0
[   28.340895][   T31] Code: 49 c7 04 24 00 00 00 00 45 31 f6 49 89 dd 48 8b 44 24 28 48 8b 7c 24 18 44 89 ee 44 89 eb 0f be 50 1b e8 62 bd ff ff 48 89 c6 <49> 8b 87 80 01 00 00 49 8b 97 98 01 00 00 48 39 c2 48 0f 43 c2 48
[   28.347084][   T31] RSP: 0018:ffffc9000011bc10 EFLAGS: 00010246
[   28.349209][   T31] RAX: 0000000000000f8e RBX: 0000000000000000 RCX: 0000000000000003
[   28.351858][   T31] RDX: 0000000000000004 RSI: 0000000000000f8e RDI: ffffffff822fdd68
[   28.354750][   T31] RBP: ffffc9000011bce8 R08: 0000000000000000 R09: ffffffff822fc100
[   28.357437][   T31] R10: 0000000000000000 R11: 0000000000000000 R12: ffffc9000011bd40
[   28.360018][   T31] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[   28.362825][   T31] FS:  0000000000000000(0000) GS:ffff888034800000(0000) knlGS:0000000000000000
[   28.365961][   T31] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   28.368279][   T31] CR2: 0000000000000180 CR3: 0000000027352004 CR4: 00000000003606b0
[   28.370939][   T31] Call Trace:
[   28.372315][   T31]  ? __lock_acquire+0x959/0x1260
[   28.374140][   T31]  shrink_node+0xd8/0x460
[   28.375847][   T31]  balance_pgdat+0x24d/0x4b0
[   28.377636][   T31]  kswapd+0x1ac/0x5e0
[   28.379302][   T31]  ? wait_woken+0xa0/0xa0
[   28.380938][   T31]  kthread+0x10b/0x140
[   28.382516][   T31]  ? balance_pgdat+0x4b0/0x4b0
[   28.384263][   T31]  ? kthread_cancel_delayed_work_sync+0x10/0x10
[   28.386530][   T31]  ret_from_fork+0x24/0x30
[   28.388196][   T31] Modules linked in: xfs libcrc32c sd_mod sr_mod cdrom serio_raw ahci libahci mptspi ata_generic pata_acpi scsi_transport_spi mptscsih mptbase vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm i2c_core ata_piix libata
[   28.395374][   T31] CR2: 0000000000000180
[   28.397135][   T31] ---[ end trace 42d4bab7295e2355 ]---
[   28.399381][   T31] RIP: 0010:shrink_node_memcg+0xa1/0x4d0
[   28.401444][   T31] Code: 49 c7 04 24 00 00 00 00 45 31 f6 49 89 dd 48 8b 44 24 28 48 8b 7c 24 18 44 89 ee 44 89 eb 0f be 50 1b e8 62 bd ff ff 48 89 c6 <49> 8b 87 80 01 00 00 49 8b 97 98 01 00 00 48 39 c2 48 0f 43 c2 48
[   28.408079][   T31] RSP: 0018:ffffc9000011bc10 EFLAGS: 00010246
[   28.410327][   T31] RAX: 0000000000000f8e RBX: 0000000000000000 RCX: 0000000000000003
[   28.412930][   T31] RDX: 0000000000000004 RSI: 0000000000000f8e RDI: ffffffff822fdd68
[   28.415567][   T31] RBP: ffffc9000011bce8 R08: 0000000000000000 R09: ffffffff822fc100
[   28.418284][   T31] R10: 0000000000000000 R11: 0000000000000000 R12: ffffc9000011bd40
[   28.421068][   T31] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[   28.423683][   T31] FS:  0000000000000000(0000) GS:ffff888034800000(0000) knlGS:0000000000000000
[   28.426549][   T31] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   28.428977][   T31] CR2: 0000000000000180 CR3: 0000000027352004 CR4: 00000000003606b0
----------

