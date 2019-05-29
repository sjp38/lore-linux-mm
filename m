Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A73EC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:32:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2AFC2415A
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:32:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="w6GpgIMW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2AFC2415A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 387FD6B026A; Wed, 29 May 2019 16:32:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3386A6B026D; Wed, 29 May 2019 16:32:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 226BA6B026E; Wed, 29 May 2019 16:32:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 056066B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 16:32:02 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id s18so3045293itl.7
        for <linux-mm@kvack.org>; Wed, 29 May 2019 13:32:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+j1iS5dNAudmx4UH+uWG9vQsSzXOCdgsKti/KKoA57M=;
        b=S2t/d4+ItvqGWtJtOVlI+81w1L/XTTEzWexsP66kLo5XdM3SmD+WzXXSiDgdBXdk2Y
         /ctN/nzWzLHXbmzxwC7a3xpOTWEWBPsIl63cYrIy+Yrw1wx1LvjY0rNXKARCWZdNK01O
         93+hlwIO/XnOUR9A2XWQKu3Cyn1LZUgpPJtPo2lIoa6vXdxDOCnPelSgui78DrM8H+u9
         9PRnTebVKzi4yI3g/SkIrX/QQH1J/Gm3PH50iuIpf98NPGLhyjA3l90X1dSlF6ecmMIG
         0hOiYdYY4OX5YjzHfYvUSKo0H0UDfNElOqoRfc7SGdYNr1ATxzr6+pM+/9ZBYkythtG7
         qwgA==
X-Gm-Message-State: APjAAAWwKEom9WITCGynBif2sRzCwOydJY1kh2Dj0gcUL+w+4jcZ30QX
	4F2eV2P+XGTc2amgmEu6kOC6U8Jh+Vr5sx6FjT7Sx/mYUeAOBZ+4DmQibT0flozu67wth+IUBHW
	ScgS0hJ6Of5FNxdtwuui4T8znNqctS4Exhy7SC2y1Q3moxVAfwkwdn7eDKUZVPwEL5Q==
X-Received: by 2002:a05:6638:605:: with SMTP id g5mr20108148jar.110.1559161921450;
        Wed, 29 May 2019 13:32:01 -0700 (PDT)
X-Received: by 2002:a05:6638:605:: with SMTP id g5mr20108094jar.110.1559161920626;
        Wed, 29 May 2019 13:32:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559161920; cv=none;
        d=google.com; s=arc-20160816;
        b=VZikJPIKPsNMdpG9+W3rwHW7nvShsSKqyXN+XV0ryRQEZlExHmmJj4wMly8m3U2fVt
         y5MxxZikIs0OLLtsJU/fD/k4fjhqJiESos9smzpl9e4OHNmFsTJxwxrkxTF68XxFMLfT
         sF2t3JG/7hKKszTy94pDWyYSzlF4uZR51906fec0f811Vwj5MK++LtPCGjWCN92mbgiv
         7n+n+mRZxSxbVfc9XDvcU4PignS/wESda2Jj4YqwvBw2tElcPKo317YVs0OAh+gk1qmi
         Ih0FwpsL3/JEA3dCrBgzJUTdTp5zVIwBPCyCOyBN81cnBS/G//6vRFTc+HW+JFykYqqW
         o5IA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=+j1iS5dNAudmx4UH+uWG9vQsSzXOCdgsKti/KKoA57M=;
        b=RoQ9ycg9Vsr3XzhiVijDi24YyZmlLVo9kJEaXV0tEcg/1QKjHed4PYqoFqt4oWnJnS
         N7aFZSCu48Z31L2baVnRFQk0esfOxrkWFuQDQ2ZXA4lYG38Frh9BqbvkQdkmfa8TQctc
         cMmXGD7KvyIvjrHqt1IhfTKgELaxxF9KUIwO7+hD1JK1YO4hI/hTTzsawphaDMbKq4UP
         VtvKCYkhzSZbrCamX2sMsX68kscHhamX0l4/IhJuG/Lz4xETcl8PyJAVcj8bBNZuqZbY
         DGhe4zHi0ZQAb7rGh3N4jgwjlHA2/SjGnOquDnSTlIYG2aQ17r2TWUpwPqHE1LdAugz/
         Dhmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=w6GpgIMW;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e9sor852986ite.30.2019.05.29.13.32.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 13:32:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=w6GpgIMW;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=+j1iS5dNAudmx4UH+uWG9vQsSzXOCdgsKti/KKoA57M=;
        b=w6GpgIMW8hIiwXx5o1J3d7Bser43fI2PfRq0K2wMU1lyLzNumJpQ5ARAbG1NExEahG
         +u/bAFy+fgsAQ5mdxsV/A8D3Q8x06C7UcgnqOhvFt8P8wgiAnIW2AtzFcqn1zBnADeeQ
         zDf6UuxZHjjPhSEeVR3KG7+Sbqid7fm/w6HsESA8MxKMNUxgTo3xYVVRph1rJH7BXEFG
         TNh77ryxkOQavb/RKDOAdtBly2PZ7pSAre/+T7urveK81n5LKBvFLOlA4/NIX8ymG9om
         d9RCTtoayKgPCkQMN57R9yNDZA+qNkFwXTt2pzPYsTy7vk2oSepZXP1ql33H/vuJJlSU
         Ki9Q==
X-Google-Smtp-Source: APXvYqy3RaoAImWLO3Q8NdcbbkYqij1DCbkDSj7fKDMoc5wdjPmduML0c53h9RnSe8d0KxuFcuKF+w==
X-Received: by 2002:a24:5252:: with SMTP id d79mr157943itb.14.1559161920322;
        Wed, 29 May 2019 13:32:00 -0700 (PDT)
Received: from [192.168.1.158] ([216.160.245.98])
        by smtp.gmail.com with ESMTPSA id d71sm190824itc.18.2019.05.29.13.31.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 13:31:59 -0700 (PDT)
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, hch@lst.de, peterz@infradead.org,
 oleg@redhat.com, gkohli@codeaurora.org, mingo@redhat.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559161526-618-1-git-send-email-cai@lca.pw>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <ad24b8de-c1dc-f52a-06af-103ceda891a6@kernel.dk>
Date: Wed, 29 May 2019 14:31:58 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <1559161526-618-1-git-send-email-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/29/19 2:25 PM, Qian Cai wrote:
> The commit 0619317ff8ba ("block: add polled wakeup task helper")
> replaced wake_up_process() with blk_wake_io_task() in
> end_swap_bio_read() which triggers a crash when running heavy swapping
> workloads.
> 
> [T114538] kernel BUG at kernel/sched/core.c:3462!
> [T114538] Process oom01 (pid: 114538, stack limit = 0x000000004f40e0c1)
> [T114538] Call trace:
> [T114538]  do_task_dead+0xf0/0xf8
> [T114538]  do_exit+0xd5c/0x10fc
> [T114538]  do_group_exit+0xf4/0x110
> [T114538]  get_signal+0x280/0xdd8
> [T114538]  do_notify_resume+0x720/0x968
> [T114538]  work_pending+0x8/0x10
> 
> This is because shortly after set_special_state(TASK_DEAD),
> end_swap_bio_read() is called from an interrupt handler that revive the
> task state to TASK_RUNNING causes __schedule() to return and trip the
> BUG() later.
> 
> [  C206] Call trace:
> [  C206]  dump_backtrace+0x0/0x268
> [  C206]  show_stack+0x20/0x2c
> [  C206]  dump_stack+0xb4/0x108
> [  C206]  blk_wake_io_task+0x7c/0x80
> [  C206]  end_swap_bio_read+0x22c/0x31c
> [  C206]  bio_endio+0x3d8/0x414
> [  C206]  dec_pending+0x280/0x378 [dm_mod]
> [  C206]  clone_endio+0x128/0x2ac [dm_mod]
> [  C206]  bio_endio+0x3d8/0x414
> [  C206]  blk_update_request+0x3ac/0x924
> [  C206]  scsi_end_request+0x54/0x350
> [  C206]  scsi_io_completion+0xf0/0x6f4
> [  C206]  scsi_finish_command+0x214/0x228
> [  C206]  scsi_softirq_done+0x170/0x1a4
> [  C206]  blk_done_softirq+0x100/0x194
> [  C206]  __do_softirq+0x350/0x790
> [  C206]  irq_exit+0x200/0x26c
> [  C206]  handle_IPI+0x2e8/0x514
> [  C206]  gic_handle_irq+0x224/0x228
> [  C206]  el1_irq+0xb8/0x140
> [  C206]  _raw_spin_unlock_irqrestore+0x3c/0x74
> [  C206]  do_task_dead+0x88/0xf8
> [  C206]  do_exit+0xd5c/0x10fc
> [  C206]  do_group_exit+0xf4/0x110
> [  C206]  get_signal+0x280/0xdd8
> [  C206]  do_notify_resume+0x720/0x968
> [  C206]  work_pending+0x8/0x10
> 
> Before the offensive commit, wake_up_process() will prevent this from
> happening by taking the pi_lock and bail out immediately if TASK_DEAD is
> set.
> 
> if (!(p->state & TASK_NORMAL))
> 	goto out;
> 
> Fix it by calling wake_up_process() if it is in a non-task context.

I like this one a lot better than the previous fix. Unless folks
object, I'll queue this up for 5.2, thanks.

-- 
Jens Axboe

