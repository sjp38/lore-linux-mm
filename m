Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BFA5C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 00:01:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3C7F218AE
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 00:01:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3C7F218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A3A16B0003; Wed, 20 Mar 2019 20:01:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 851FB6B0006; Wed, 20 Mar 2019 20:01:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CB8F6B0007; Wed, 20 Mar 2019 20:01:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12E906B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 20:01:56 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o4so4182582pgl.6
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 17:01:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-transfer-encoding;
        bh=nF2xAbhk3mPshs55wC9SsICztHcvB9dz4ck+7dj9wE8=;
        b=Q4HucdSlrUj1dFuPTxhkywFXMPyasowBj1wU7X7bfZFOMRDXL6c1f3Q2PHTDoj19zA
         6EPF58/GkKRGf4y39faPAPNGSpKfNvfq1MwVJvHqgoa7J+/10xQ7C6GtT7Aes8zeQBy7
         CUgEiDCAHoSeD1NlAXWHhp3RDYWjmprBVjCexsAye5oX1k/MRxBsKitctj6PqQ9yB/j5
         hrTvz2T3ehMRfnT3mURjoWJo8m7MQhOR4fMh1ZQEF//t7NYsX4NBnWAWDP9bSNlh2GXI
         8ZRKSpaUU/DzQRTJHQjLqkEkoFivoIzpfrj5hOJpV9R4Exi15p1fzelpvWCCtqJFLyGs
         cY1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUiCiuWtpAQNtvhPNXkxszCVtOXae+KsGnllnhvfRFn05sZvImQ
	r6mxvX6xY0Ykv1vxEdIeW56zeDPYtKWOkcO4Wd7CiZpSdYQfRoBj18bVGKG3woMY4voBd95Mb5s
	2gSEVVQxfPAktepBaSJ2QNa7mJ3sFccUJjqWFc5STceuBcGIwRa91IGvyHoQ9vxZfZA==
X-Received: by 2002:a65:4806:: with SMTP id h6mr656465pgs.408.1553126515572;
        Wed, 20 Mar 2019 17:01:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzf9apgb0JmRkmMiRyhXx7lSCzA5kzs/x/gh75+RZXHconPpmrzzPaNL7dVGWKnS9NpF3q
X-Received: by 2002:a65:4806:: with SMTP id h6mr656299pgs.408.1553126513301;
        Wed, 20 Mar 2019 17:01:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553126513; cv=none;
        d=google.com; s=arc-20160816;
        b=ysTwzKlLCgQW/8qThDZ7AWv1E/W66CqGA/D2KrER/mR+cTys6SobozIbD1uYAPssod
         44639lFRYdFl/dtQ41PF5hBAVvWNr7AwYcmUy990RhseuCWX+mhG7CuSoNAMMcPB9EB8
         e6GGGuHMxBRJDH2SSIZ7HHu+2GGycPrUJY+Y0DYjzjmhE2Q4zs+iZzNk5tI1UT2p+wXP
         lfStEJp+E9IHkobkCI9UrxpGEEr8iqtv5+K8+k8KPyaYO1ZUR3L1j5A2gCtdbIuVsdw9
         JHKrMj/GQJlrjCI1AcXdJKr8YBb5eXbCJ//HGIyq2zxKJ2ONUDmWoPepV0jsPN7eEuVp
         78dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:subject:cc:to
         :from:date;
        bh=nF2xAbhk3mPshs55wC9SsICztHcvB9dz4ck+7dj9wE8=;
        b=GMtOWyozu3MWDJ5vSl9IdyKUnXe7dmBBMUwH/iQ82VQsO8rnGTDE7iWm6ghEpGNX0e
         57DmhQUtwQPq4CpEWE5AGMWGvbbj0mFfLZcmmxnYw+SpsBmSQxxCeGMvdWSBBKsCEO7N
         HHlqNQ4Z3Gkv2VZ2ELzdnC9bcKaWO6k6g4AuqRDwkgTK/3NAh3hOdlSbiKxujQ18Wauk
         kp2gD+ifTuPSQrsSKojshFcJ2BIzHhFZWQhn7dL/4BMRTwqYfH0z5EwTXF2HtVJvjdIC
         D+SsA9AEgZcRa6v7V7UtQV+nAunPzviMMry6dNwJ5RlKtNoY+fXEshDA2/86Ly+qLJq/
         Au6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v5si2783129pgr.489.2019.03.20.17.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 17:01:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id C1C4B9EE;
	Thu, 21 Mar 2019 00:01:52 +0000 (UTC)
Date: Wed, 20 Mar 2019 17:01:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>
Subject: Fw: [Bug 202919] New: Bad page map in process syz-executor.5 
 pte:9100000081 pmd:47c67067
Message-Id: <20190320170151.2ed757a48e892ebc05922389@linux-foundation.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


kcov_mmap()/kcov_fault_in_area() appear to have produced a pte which
confused _vm_normal_page().  Could someone please take a look?


Begin forwarded message:

Date: Thu, 14 Mar 2019 15:06:47 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: akpm@linux-foundation.org
Subject: [Bug 202919] New: Bad page map in process syz-executor.5  pte:9100000081 pmd:47c67067


https://bugzilla.kernel.org/show_bug.cgi?id=202919

            Bug ID: 202919
           Summary: Bad page map in process syz-executor.5  pte:9100000081
                    pmd:47c67067
           Product: Memory Management
           Version: 2.5
    Kernel Version: 5.0.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Page Allocator
          Assignee: akpm@linux-foundation.org
          Reporter: zhanggen12@hotmail.com
        Regression: No

Created attachment 281823
  --> https://bugzilla.kernel.org/attachment.cgi?id=281823&action=edit
bad page map

BUG: Bad page map in process syz-executor.5  pte:9100000081 pmd:47c67067
addr:00000000768464c8 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:18f
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Not tainted 5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 _vm_normal_page+0x111/0x2b0 mm/memory.c:612
 zap_pte_range mm/memory.c:1063 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x89b/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: 7d a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48
89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83
4b a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
BUG: Bad page map in process syz-executor.5  pte:5309000000a1 pmd:47c67067
addr:000000002e2065c3 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:190
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 _vm_normal_page+0x111/0x2b0 mm/memory.c:612
 zap_pte_range mm/memory.c:1063 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x89b/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: 7d a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48
89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83
4b a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 5401e6ffffffffff
BUG: Bad page map in process syz-executor.5  pte:ac32000000000000 pmd:47c67067
addr:000000008adbb032 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:192
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: 7d a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48
89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83
4b a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 3ffffb6ffffff
BUG: Bad page map in process syz-executor.5  pte:9200000082 pmd:47c67067
addr:00000000d83b3dac vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:193
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: 7d a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48
89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83
4b a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 4c02787f887fffff
BUG: Bad page map in process syz-executor.5  pte:9b0f00ef00000000 pmd:47c67067
addr:000000008533c1ed vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:196
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: 7d a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48
89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83
4b a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
BUG: Bad page map in process syz-executor.5  pte:9300000083 pmd:47c67067
addr:00000000117ad9ce vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:197
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 _vm_normal_page+0x111/0x2b0 mm/memory.c:612
 zap_pte_range mm/memory.c:1063 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x89b/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: 7d a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48
89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83
4b a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
BUG: Bad page map in process syz-executor.5  pte:1fe90000000004a1 pmd:47c67067
addr:00000000632caa85 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:198
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 _vm_normal_page+0x111/0x2b0 mm/memory.c:612
 zap_pte_range mm/memory.c:1063 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x89b/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: 7d a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48
89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83
4b a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
BUG: Bad page map in process syz-executor.5  pte:00040017 pmd:47c67067
page:ffffea0000001000 count:0 mapcount:-129 mapping:0000000000000000 index:0x0
flags: 0x0()
raw: 0000000000000000 ffff88807fffa270 ffff88807fffa270 0000000000000000
raw: 0000000000000000 0000000000000006 00000000ffffff7e 0000000000000000
page dumped because: bad pte
addr:00000000b5a11157 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:199
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1092 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x144b/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: 7d a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48
89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83
4b a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 2403b5f00b7fffff
BUG: Bad page map in process syz-executor.5  pte:48941fe900000000 pmd:47c67067
addr:00000000ee146683 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:19a
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: 7d a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48
89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83
4b a6 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 3ffffb5ffffff
BUG: Bad page map in process syz-executor.5  pte:9400000084 pmd:47c67067
addr:000000003ad02655 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:19b
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 3fffffffffd7f
BUG: Bad page map in process syz-executor.5  pte:00050000 pmd:47c67067
addr:00000000d5308cc0 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:19d
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 2802db6fffffffff
BUG: Bad page map in process syz-executor.5  pte:5249200000000000 pmd:47c67067
addr:000000005f7bdb6f vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:19e
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
BUG: Bad page map in process syz-executor.5  pte:9500000085 pmd:47c67067
addr:000000000c5b1271 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:19f
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 _vm_normal_page+0x111/0x2b0 mm/memory.c:612
 zap_pte_range mm/memory.c:1063 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x89b/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
BUG: Bad page map in process syz-executor.5  pte:20001458000008a1 pmd:47c67067
addr:000000004f1778f6 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:1a0
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 _vm_normal_page+0x111/0x2b0 mm/memory.c:612
 zap_pte_range mm/memory.c:1063 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x89b/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 3fffffffffd7f
BUG: Bad page map in process syz-executor.5  pte:00050000 pmd:47c67067
addr:000000009c3df739 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:1a1
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 50003eefffffffff
BUG: Bad page map in process syz-executor.5  pte:a782200000000000 pmd:47c67067
addr:00000000a298f08a vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:1a2
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 3ffffb4ffffff
BUG: Bad page map in process syz-executor.5  pte:9600000086 pmd:47c67067
addr:000000001f1892ea vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:1a3
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 3fffffffffd7f
BUG: Bad page map in process syz-executor.5  pte:00050000 pmd:47c67067
addr:0000000088420d0c vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:1a5
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 5c00f06fffffffff
BUG: Bad page map in process syz-executor.5  pte:be1f200000000000 pmd:47c67067
addr:000000009c08436b vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:1a6
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
BUG: Bad page map in process syz-executor.5  pte:9700000087 pmd:47c67067
addr:00000000e0488400 vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:1a7
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 _vm_normal_page+0x111/0x2b0 mm/memory.c:612
 zap_pte_range mm/memory.c:1063 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x89b/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
BUG: Bad page map in process syz-executor.5  pte:2000800000000ca1 pmd:47c67067
addr:000000002e00ad5a vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:1a8
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 _vm_normal_page+0x111/0x2b0 mm/memory.c:612
 zap_pte_range mm/memory.c:1063 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x89b/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
swap_info_get: Bad swap file entry 3fffffffffc7f
BUG: Bad page map in process syz-executor.5  pte:00070000 pmd:47c67067
addr:000000006a47b55c vm_flags:100400fb anon_vma:          (null)
mapping:000000009265a729 index:1a9
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
 zap_pte_range mm/memory.c:1137 [inline]
 zap_pmd_range mm/memory.c:1192 [inline]
 zap_pud_range mm/memory.c:1221 [inline]
 zap_p4d_range mm/memory.c:1242 [inline]
 unmap_page_range+0x109e/0x1950 mm/memory.c:1263
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN PTI
CPU: 0 PID: 30290 Comm: syz-executor.5 Tainted: G    B             5.0.2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
RIP: 0010:__read_once_size include/linux/compiler.h:193 [inline]
RIP: 0010:compound_head include/linux/page-flags.h:143 [inline]
RIP: 0010:migration_entry_to_page include/linux/swapops.h:210 [inline]
RIP: 0010:zap_pte_range mm/memory.c:1133 [inline]
RIP: 0010:zap_pmd_range mm/memory.c:1192 [inline]
RIP: 0010:zap_pud_range mm/memory.c:1221 [inline]
RIP: 0010:zap_p4d_range mm/memory.c:1242 [inline]
RIP: 0010:unmap_page_range+0xdb8/0x1950 mm/memory.c:1263
Code: e3 ff 48 8b 54 24 18 48 b8 00 00 00 00 00 ea ff ff 48 c1 e2 06 48 01 d0
48 89 44 24 28 48 83 c0 08 48 89 44 24 60 48 c1 e8 03 <42> 80 3c 30 00 0f 85 e5
09 00 00 4c 8b 6c 24 28 31 ff 49 8b 45 08
RSP: 0018:ffff88804871f700 EFLAGS: 00010206
RAX: 000630bffffffff9 RBX: fe73200000000000 RCX: ffffffff8158a3cc
RDX: 00319bffffffffc0 RSI: ffffffff8158a9c0 RDI: 0000000000000007
RBP: 0000000000000000 R08: ffff88804af72f80 R09: fffffbfff0948d33
R10: fffffbfff0948d33 R11: ffffffff84a4699b R12: ffff88804871f9b8
R13: 000000000000001f R14: dffffc0000000000 R15: 00007f26a4071000
FS:  00007f26a3070700(0000) GS:ffff88806d000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004588cf CR3: 0000000004426006 CR4: 00000000001606f0
Call Trace:
 unmap_single_vma+0x198/0x300 mm/memory.c:1308
 unmap_vmas+0x172/0x280 mm/memory.c:1339
 exit_mmap+0x27d/0x4a0 mm/mmap.c:3139
 __mmput kernel/fork.c:1047 [inline]
 mmput+0xd0/0x3b0 kernel/fork.c:1068
 exit_mm kernel/exit.c:545 [inline]
 do_exit+0xa55/0x2e00 kernel/exit.c:862
 do_group_exit+0x125/0x350 kernel/exit.c:979
 get_signal+0x362/0x1c60 kernel/signal.c:2575
 do_signal+0x8f/0x1660 arch/x86/kernel/signal.c:816
 exit_to_usermode_loop+0x16b/0x1c0 arch/x86/entry/common.c:162
 prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
 do_syscall_64+0x3da/0x4e0 arch/x86/entry/common.c:293
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4588f9
Code: Bad RIP value.
RSP: 002b:00007f26a306fcf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 000000000072bf00 RCX: 00000000004588f9
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf08 R08: 00007f26a3070700 R09: 00007f26a3070700
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 0000000000000000 R14: 00007f26a30709c0 R15: 00007f26a3070700
Modules linked in:
Dumping ftrace buffer:
   (ftrace buffer empty)
---[ end trace 72dd5bdc713f57dd ]---
RIP: 0010:__read_once_size include/linux/compiler.h:193 [inline]
RIP: 0010:compound_head include/linux/page-flags.h:143 [inline]
RIP: 0010:migration_entry_to_page include/linux/swapops.h:210 [inline]
RIP: 0010:zap_pte_range mm/memory.c:1133 [inline]
RIP: 0010:zap_pmd_range mm/memory.c:1192 [inline]
RIP: 0010:zap_pud_range mm/memory.c:1221 [inline]
RIP: 0010:zap_p4d_range mm/memory.c:1242 [inline]
RIP: 0010:unmap_page_range+0xdb8/0x1950 mm/memory.c:1263
Code: e3 ff 48 8b 54 24 18 48 b8 00 00 00 00 00 ea ff ff 48 c1 e2 06 48 01 d0
48 89 44 24 28 48 83 c0 08 48 89 44 24 60 48 c1 e8 03 <42> 80 3c 30 00 0f 85 e5
09 00 00 4c 8b 6c 24 28 31 ff 49 8b 45 08
RSP: 0018:ffff88804871f700 EFLAGS: 00010206
RAX: 000630bffffffff9 RBX: fe73200000000000 RCX: ffffffff8158a3cc
RDX: 00319bffffffffc0 RSI: ffffffff8158a9c0 RDI: 0000000000000007
RBP: 0000000000000000 R08: ffff88804af72f80 R09: fffffbfff0948d33
R10: fffffbfff0948d33 R11: ffffffff84a4699b R12: ffff88804871f9b8
R13: 000000000000001f R14: dffffc0000000000 R15: 00007f26a4071000
FS:  00007f26a3070700(0000) GS:ffff88806d000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004588cf CR3: 0000000004426006 CR4: 00000000001606f0

-- 
You are receiving this mail because:
You are the assignee for the bug.

