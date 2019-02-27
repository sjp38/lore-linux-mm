Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C153C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:38:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 560C320C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:38:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 560C320C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E75B58E001B; Wed, 27 Feb 2019 12:38:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFA3C8E0001; Wed, 27 Feb 2019 12:38:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC3F88E001B; Wed, 27 Feb 2019 12:38:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B18E8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:38:56 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u12so7275748edo.5
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:38:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1JDZyMRpYHsQ5xhzp+bVlGOJKxoCSrILZkjIoH7AIL8=;
        b=dDQ8u55zHkZ6O+aRxqe9oO/LwvleY2oVDffUriDX/2qPRYA2TgxWmV/3yNyCVoy+A5
         5e5n6A7eDOS+h3gTGOX4yfdW8wtsc5znTXRWrk2lovtRJfFSFJCPzX3qV8M7sgxYNr9w
         Lt6ufqGkdxl+fFmwcplL7WsMgOxkZsqWdArVQGIfQdFKCLIbUqzpawW0Gg0KbDcBSGDN
         NvVn/DZZ+6rB0T8A1zxfXjgarCUKIgFxMvCylz25QWgZFduuIwNcNvX6V7MtzKyMHPvV
         AScq0HGLBgS/9Hbbzbs4utJz2cby3wgqcf3/687+xvw12bBpUS6xb8I3mIVu27k6isUw
         O5NQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAubQVAQ7v5PGL1HM8HYJUwU9jE3Qkety6LxX+t1EGQn06yOjo3RA
	Mw1tid5knzAdQ3AKRQj24uBR1f02ztWVPOGuietCQwBhAOWes7drDoigkCoJIgZPRNWrJmSe317
	b3KUcak8EeMyqukob6nJcN1tRWoWrHg3zau4/8vfZ/F1pnAwWXK0mzVVQcmp8h7p3yg==
X-Received: by 2002:a17:906:1b10:: with SMTP id o16mr2344690ejg.184.1551289135968;
        Wed, 27 Feb 2019 09:38:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYkkrmQ2y3nXXYIrO+wXwp0U8TzGi037HYotM2Nb5nehc1mDkFwZjZUYnqKVVzBQNYjZ49z
X-Received: by 2002:a17:906:1b10:: with SMTP id o16mr2344648ejg.184.1551289134952;
        Wed, 27 Feb 2019 09:38:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551289134; cv=none;
        d=google.com; s=arc-20160816;
        b=hQ2kgUgw3ejhKsqDU6PnJucldiLsMPqYoySeJ1xlmROz0QYpNrPkV8zd0zrBWIYK4l
         Vai5VXZ7QZHgA6AJXSfyruP3G3t/yTq4hMKbJu9Kd8g5sYQfOFU+c09mvuSEWGbodKiq
         cJHrV0B+KuSmoTiyyOkiFeQAOLxkY+u9gbDT46j8c6Kt+eUMMnYEphoAWREeHLaRQ0Ak
         fXu9sc81FMD/YeI6J7bU12qbKJwsQATvyeoRTl2RUhYC9qBSMVx5Hraqw7+qMLaryjEW
         88M/uY0tPRI7rjec8sJnm4zt1xXHYeEkzNn7Hni4OCC6IOhxDt0mssZbHqxARj4+RdKu
         2lmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1JDZyMRpYHsQ5xhzp+bVlGOJKxoCSrILZkjIoH7AIL8=;
        b=R1ns7j5qv7WL4yFY5iWSSzWj5HrAjR6HqudYZpA8tftNmlojKTExHw8uewgkPzhnNJ
         fb1JV0IuWxidx8w5Fl3mqzSE2i9V3Y8j3UtSdLtxfOjx6g3NU6aNlP+TVknQTYjSKUqI
         zHY5u/6L8iNDWZ2lIThvenx4XINDzSxbE7DeW4R3nENjS4LmKr37DxQ0d/bCyGkpf9ee
         8k7xtMpwJA1SR4PS00KqJfZNm9urdnAgjZKG7dscCl1dnfAhi1xYX5H5MXV+yZXyEZSL
         3xdS40ADQxZVUh5gLeqam7EIrHcjKRkAVsuRd+I17BuOtZOc6YTIlV1cCAwWV4MgvzuZ
         Fi1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ca10si535924ejb.323.2019.02.27.09.38.54
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:38:54 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A8509A78;
	Wed, 27 Feb 2019 09:38:53 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BC7E13F703;
	Wed, 27 Feb 2019 09:38:52 -0800 (PST)
Date: Wed, 27 Feb 2019 17:38:50 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] mm/page_ext: fix an imbalance with kmemleak
Message-ID: <20190227173849.GG125513@arrakis.emea.arm.com>
References: <20190227173147.75650-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227173147.75650-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 12:31:47PM -0500, Qian Cai wrote:
> After offlined a memory block, kmemleak scan will trigger a crash, as it
> encounters a page ext address that has already been freed during memory
> offlining. At the beginning in alloc_page_ext(), it calls
> kmemleak_alloc(), but it does not call kmemleak_free() in
> free_page_ext().
> 
> BUG: unable to handle kernel paging request at ffff888453d00000
> PGD 128a01067 P4D 128a01067 PUD 128a04067 PMD 47e09e067 PTE 800ffffbac2ff060
> Oops: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
> CPU: 1 PID: 1594 Comm: bash Not tainted 5.0.0-rc8+ #15
> Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9, BIOS U20 10/25/2017
> RIP: 0010:scan_block+0xb5/0x290
> Code: 85 6e 01 00 00 48 b8 00 00 30 f5 81 88 ff ff 48 39 c3 0f 84 5b 01
> 00 00 48 89 d8 48 c1 e8 03 42 80 3c 20 00 0f 85 87 01 00 00 <4c> 8b 3b
> e8 f3 0c fa ff 4c 39 3d 0c 6b 4c 01 0f 87 08 01 00 00 4c
> RSP: 0018:ffff8881ec57f8e0 EFLAGS: 00010082
> RAX: 0000000000000000 RBX: ffff888453d00000 RCX: ffffffffa61e5a54
> RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff888453d00000
> RBP: ffff8881ec57f920 R08: fffffbfff4ed588d R09: fffffbfff4ed588c
> R10: fffffbfff4ed588c R11: ffffffffa76ac463 R12: dffffc0000000000
> R13: ffff888453d00ff9 R14: ffff8881f80cef48 R15: ffff8881f80cef48
> FS:  00007f6c0e3f8740(0000) GS:ffff8881f7680000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffff888453d00000 CR3: 00000001c4244003 CR4: 00000000001606a0
> Call Trace:
>  scan_gray_list+0x269/0x430
>  kmemleak_scan+0x5a8/0x10f0
>  kmemleak_write+0x541/0x6ca
>  full_proxy_write+0xf8/0x190
>  __vfs_write+0xeb/0x980
>  vfs_write+0x15a/0x4f0
>  ksys_write+0xd2/0x1b0
>  __x64_sys_write+0x73/0xb0
>  do_syscall_64+0xeb/0xaaa
>  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> RIP: 0033:0x7f6c0dad73b8
> Code: 89 02 48 c7 c0 ff ff ff ff eb b3 0f 1f 80 00 00 00 00 f3 0f 1e fa
> 48 8d 05 65 63 2d 00 8b 00 85 c0 75 17 b8 01 00 00 00 0f 05 <48> 3d 00
> f0 ff ff 77 58 c3 0f 1f 80 00 00 00 00 41 54 49 89 d4 55
> RSP: 002b:00007ffd5b863cb8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00007f6c0dad73b8
> RDX: 0000000000000005 RSI: 000055a9216e1710 RDI: 0000000000000001
> RBP: 000055a9216e1710 R08: 000000000000000a R09: 00007ffd5b863840
> R10: 000000000000000a R11: 0000000000000246 R12: 00007f6c0dda9780
> R13: 0000000000000005 R14: 00007f6c0dda4740 R15: 0000000000000005
> Modules linked in: nls_iso8859_1 nls_cp437 vfat fat kvm_intel kvm
> irqbypass efivars ip_tables x_tables xfs sd_mod ahci libahci igb
> i2c_algo_bit libata i2c_core dm_mirror dm_region_hash dm_log dm_mod
> efivarfs
> CR2: ffff888453d00000
> ---[ end trace ccf646c7456717c5 ]---
> RIP: 0010:scan_block+0xb5/0x290
> Code: 85 6e 01 00 00 48 b8 00 00 30 f5 81 88 ff ff 48 39 c3 0f 84 5b 01
> 00 00 48 89 d8 48 c1 e8 03 42 80 3c 20 00 0f 85 87 01 00 00 <4c> 8b 3b
> e8 f3 0c fa ff 4c 39 3d 0c 6b 4c 01 0f 87 08 01 00 00 4c
> RSP: 0018:ffff8881ec57f8e0 EFLAGS: 00010082
> RAX: 0000000000000000 RBX: ffff888453d00000 RCX: ffffffffa61e5a54
> RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff888453d00000
> RBP: ffff8881ec57f920 R08: fffffbfff4ed588d R09: fffffbfff4ed588c
> R10: fffffbfff4ed588c R11: ffffffffa76ac463 R12: dffffc0000000000
> R13: ffff888453d00ff9 R14: ffff8881f80cef48 R15: ffff8881f80cef48
> FS:  00007f6c0e3f8740(0000) GS:ffff8881f7680000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffff888453d00000 CR3: 00000001c4244003 CR4: 00000000001606a0
> Kernel panic - not syncing: Fatal exception
> Shutting down cpus with NMI
> Kernel Offset: 0x24c00000 from 0xffffffff81000000 (relocation range:
> 0xffffffff80000000-0xffffffffbfffffff)
> ---[ end Kernel panic - not syncing: Fatal exception ]---
> 
> Signed-off-by: Qian Cai <cai@lca.pw>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

