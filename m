Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58D97C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:26:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 142BA2415A
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:26:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Hvkcvhl5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 142BA2415A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A69B6B026A; Wed, 29 May 2019 16:26:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 956AD6B026D; Wed, 29 May 2019 16:26:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86C316B026E; Wed, 29 May 2019 16:26:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6067F6B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 16:26:07 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id m5so814687uak.11
        for <linux-mm@kvack.org>; Wed, 29 May 2019 13:26:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=1ST3Wiu11ivfdAEvM0Ly2pAInzScgdv/JYNtE1R9Tmw=;
        b=iZAoHygXhLXhsSCxCzfrOmyNWtzrPIuPVu4Fe1AvwRSHX7wAPS9zo9oShtJgTL+6fS
         yj2cS9luHlPbyIOsLw1PjPIIG3RAdjvAl6nBvA+GU1AiKMprcs+aOiHcwJtp+nM83FxK
         19+4ln7rx/NzV3TsIjtW4tATMG8BExkpvlCuVvqa+pRvtC8vMFflxXKFeHaV13z+N2qc
         ecIToAduQMyjaaXKGcRTXdvzbukENDMTHe+Cxe09VIMQ79r9mhOF+Z9BidQxLSWiZsct
         sZ9qXxeAg1JtPrGd6sCHT/2JonntgEhrTlViQSxoelLi2HvV/eCPgXvnxn5bDN7dfGkh
         RhkA==
X-Gm-Message-State: APjAAAU9YieGjtQwzzc+gSEQ+B8xbvcXdCFK88esK8GtX8P3IIzkVFNC
	mq+ZXUHDHPzn0M0XCJItAOlkXgpPY9VTZlX+9isxxen4X7JaIApjygOr0+zeOIUatO2BU4CJHIf
	16R8HJWWN1Pff3n1xmgUtGWYm0URmSyikWldf9irLKT1/CLzyM4/ton5W6ZAOho5Stw==
X-Received: by 2002:ab0:65c8:: with SMTP id n8mr5349048uaq.35.1559161567026;
        Wed, 29 May 2019 13:26:07 -0700 (PDT)
X-Received: by 2002:ab0:65c8:: with SMTP id n8mr5348959uaq.35.1559161566295;
        Wed, 29 May 2019 13:26:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559161566; cv=none;
        d=google.com; s=arc-20160816;
        b=K5orcP1WMJTNPQrlOWzU6aoNzafWuA+fcFqL5HKyYjBNrgn2EjhFqtJPFe6HEYPEcH
         Tuf+6i6sc+DvLAajc7EyIhH6G+ghClowdO5oSterfb+3dWQTSe0mx2nxHCmwsKkmjt7j
         AeSypooFWtX0eiKGCFqHJ/r/CBEyONueJSU+Bj9w0gA0tYSD9vuKYWMQBHudBBLc58GS
         uAZsjyhwV0NCHe+hNPY1fEx+kXO9HUttatk/PzOhGuMtDRsMXpKcb3RMyEiJpeW27TbC
         wOytlIt7CHBk9zFS1nhI/anZVCSMDMqFmMM744GGGPuDV/8WtilBwp/udCR+o3rIz8BL
         Iraw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=1ST3Wiu11ivfdAEvM0Ly2pAInzScgdv/JYNtE1R9Tmw=;
        b=NvDgtZ/b2a9uGdhjH7Q2rqS21yuBXPCeRbFgkgWaPeV6jwEDEmR61TRIZlTVadSPYg
         pV8V1SPSPJSU8cHqCdG8xizk6qfgLft4iFOkzqJfYPZuhrTBWzSOwRuWicS2grCUpOD1
         Sueo90X81BCwIymDaVke45g7V3xuhFpR6QF08v39evFbVfG9nUJRZPZDSSoM1/a59sep
         gfRK045U6MjYSb0vc6ySC+EFnhNC/bde6qS/7XVkX7xRFtvl1+4lhwmcpyvsrmnzXMft
         sZbhADSQD/34VbeaAc3mpw3VVUDgPQGVwDxjuRg4dGc8aBi+sobFhLGl+DdOgp2e0Fhn
         5VkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Hvkcvhl5;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w1sor304737uap.52.2019.05.29.13.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 13:26:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Hvkcvhl5;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=1ST3Wiu11ivfdAEvM0Ly2pAInzScgdv/JYNtE1R9Tmw=;
        b=Hvkcvhl5O83DvR3Z5w+npUq2XaOH0e5T7Y4TtsY60VcZ065NPPR3kIlKZon29rTSYD
         7eO4uppCfMTiUDxe5U9/9UmoBETLTT4j4wbl7qfn7uU4El0XH8sd8sXSSh3i+ePtVfPm
         vEqMBs8AWM0fw5Bu1oLmmwoCvHkEKvNKgcB7t0Czfh5v0jCapVVg9ZToNQJrdS7oAsHx
         fYqJJWj38HEKsuPY4QYlk2oh1+PKmndwwUAhsIA9+VluWUfdvjCuzs6TrGgwjBQ6512G
         /VyZA5K+gi8yFk4/1t1ISqaRHAKQG8PLwNduWaBN645MgEThjBiiL+YyXA8rAVt7h1o6
         lOqQ==
X-Google-Smtp-Source: APXvYqxY9aOuURIZ1sHkvE/NIWxwvXR+y0F7Q2SE+lU807QKHa4GSW8TKn/Q5MBJV2wxoWDCGBgXtA==
X-Received: by 2002:ab0:5a07:: with SMTP id l7mr30621189uad.78.1559161565870;
        Wed, 29 May 2019 13:26:05 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id x71sm329206vkd.24.2019.05.29.13.26.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 13:26:05 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: axboe@kernel.dk
Cc: akpm@linux-foundation.org,
	hch@lst.de,
	peterz@infradead.org,
	oleg@redhat.com,
	gkohli@codeaurora.org,
	mingo@redhat.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] block: fix a crash in do_task_dead()
Date: Wed, 29 May 2019 16:25:26 -0400
Message-Id: <1559161526-618-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 0619317ff8ba ("block: add polled wakeup task helper")
replaced wake_up_process() with blk_wake_io_task() in
end_swap_bio_read() which triggers a crash when running heavy swapping
workloads.

[T114538] kernel BUG at kernel/sched/core.c:3462!
[T114538] Process oom01 (pid: 114538, stack limit = 0x000000004f40e0c1)
[T114538] Call trace:
[T114538]  do_task_dead+0xf0/0xf8
[T114538]  do_exit+0xd5c/0x10fc
[T114538]  do_group_exit+0xf4/0x110
[T114538]  get_signal+0x280/0xdd8
[T114538]  do_notify_resume+0x720/0x968
[T114538]  work_pending+0x8/0x10

This is because shortly after set_special_state(TASK_DEAD),
end_swap_bio_read() is called from an interrupt handler that revive the
task state to TASK_RUNNING causes __schedule() to return and trip the
BUG() later.

[  C206] Call trace:
[  C206]  dump_backtrace+0x0/0x268
[  C206]  show_stack+0x20/0x2c
[  C206]  dump_stack+0xb4/0x108
[  C206]  blk_wake_io_task+0x7c/0x80
[  C206]  end_swap_bio_read+0x22c/0x31c
[  C206]  bio_endio+0x3d8/0x414
[  C206]  dec_pending+0x280/0x378 [dm_mod]
[  C206]  clone_endio+0x128/0x2ac [dm_mod]
[  C206]  bio_endio+0x3d8/0x414
[  C206]  blk_update_request+0x3ac/0x924
[  C206]  scsi_end_request+0x54/0x350
[  C206]  scsi_io_completion+0xf0/0x6f4
[  C206]  scsi_finish_command+0x214/0x228
[  C206]  scsi_softirq_done+0x170/0x1a4
[  C206]  blk_done_softirq+0x100/0x194
[  C206]  __do_softirq+0x350/0x790
[  C206]  irq_exit+0x200/0x26c
[  C206]  handle_IPI+0x2e8/0x514
[  C206]  gic_handle_irq+0x224/0x228
[  C206]  el1_irq+0xb8/0x140
[  C206]  _raw_spin_unlock_irqrestore+0x3c/0x74
[  C206]  do_task_dead+0x88/0xf8
[  C206]  do_exit+0xd5c/0x10fc
[  C206]  do_group_exit+0xf4/0x110
[  C206]  get_signal+0x280/0xdd8
[  C206]  do_notify_resume+0x720/0x968
[  C206]  work_pending+0x8/0x10

Before the offensive commit, wake_up_process() will prevent this from
happening by taking the pi_lock and bail out immediately if TASK_DEAD is
set.

if (!(p->state & TASK_NORMAL))
	goto out;

Fix it by calling wake_up_process() if it is in a non-task context.

Fixes: 0619317ff8ba ("block: add polled wakeup task helper")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 include/linux/blkdev.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 592669bcc536..290eb7528f54 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1803,7 +1803,7 @@ static inline void blk_wake_io_task(struct task_struct *waiter)
 	 * that case, we don't need to signal a wakeup, it's enough to just
 	 * mark us as RUNNING.
 	 */
-	if (waiter == current)
+	if (waiter == current && in_task())
 		__set_current_state(TASK_RUNNING);
 	else
 		wake_up_process(waiter);
-- 
1.8.3.1

