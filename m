Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70331C28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 22:44:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A758242BD
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 22:44:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Lua8D0OE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A758242BD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4DBF6B026A; Wed, 29 May 2019 18:44:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD6726B026D; Wed, 29 May 2019 18:44:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A79AA6B026E; Wed, 29 May 2019 18:44:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CEA96B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 18:44:27 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id c4so896729pgm.21
        for <linux-mm@kvack.org>; Wed, 29 May 2019 15:44:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fewtZHvqNRuxeNR2MkXrmWfSufOEqiOnJ1Xvk3H9424=;
        b=g8XFeoolG0ISu33/g1iB2w8tB37tGxFt0VJfxhOg23LkURfqaVp57nntjfAdLBvb7u
         Sc5SWQupxD9QHQZqYl3gsPC6G7BjXmGtpIr0HzFBn99dZ8RmIedM1h4wMaCsmvyMZiL9
         KCxQBbrE4WNH+m1TRJwLJu3Ac+Y1JgGzIhJ5aTCw9B9XRkqmdLfjDy6IBK3QnY1JzeDm
         LlHQMy73ROI5xQqIi9i8oXvFlhJGsfzQusqIKNe1xlF8rhK50MOvxryqtu3ufoNSp0C4
         A3ypakZibdsa7CWdVITU9G48oYfJrTU5B+Ddxg6SsTGxt0NRcJvzkDq9sa8mCiDERlt1
         cS1A==
X-Gm-Message-State: APjAAAUQqGSTTCWYT6bs5huPkNBUroV4exPNXS8MViEzwmEv4tgz7uTA
	35KahxbajCdLqQ/ryLloXsnoXjgTocOoKJmb+81CzebdQ8KMBku58bhatLPj6yNMtoqAmQ5r5Y0
	efhli9WwXuWTVelQy94dk7B3Jg/Lo/dBLxfTcBjcm8ev1RCrXjsDTAtqEDnxOHMRhjw==
X-Received: by 2002:a17:902:9348:: with SMTP id g8mr417354plp.174.1559169867046;
        Wed, 29 May 2019 15:44:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoYuDFbFfi9//pRRRlodhWiHsGKPIGUKymK6vh1+gPNKTwAu4R3Wc05Xd4ikAses8cE8oW
X-Received: by 2002:a17:902:9348:: with SMTP id g8mr417263plp.174.1559169866060;
        Wed, 29 May 2019 15:44:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559169866; cv=none;
        d=google.com; s=arc-20160816;
        b=nCcR/MQKSi0KbueKWyapvw2+TV0Oa7Is4ZekGKheIjSseHofMH4gLRt70wl/iV22Lt
         uc9bBTVYxdwkb+cbP42xD3o/WPKaXaNkfZZFwu1ZqUy6hG3Lp/hAbUY54RjkDFAQlmAx
         41MuysK/UdnBGEkOiqEZR3NzQUhuEhrElXhtVdZFiXM2F1voNdr3FWqKCxtTtJmxp31H
         G/gcaUhDOybDNvzNqrVeX1bDAjREx+1XpVw5GUCt5jd6zE5daGcyL4kKXr+U/USsI92K
         KKw2vUb+C18xkq1/vCffIl/3CYQcShX2Y/Wor4+wT+H36E0XtdBHQ/uUaQQRDxMc5xKK
         483A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fewtZHvqNRuxeNR2MkXrmWfSufOEqiOnJ1Xvk3H9424=;
        b=kifONEsWBsYY04L0Ujx6rxTr9K8YEMD9XCeVFdMzz5/TjinG6OeziGT1nqGN3A7Ser
         cAOARPm8jY1/TW+SAoBB2z6Q6Abtm5xHbIPG2pKygF8Ukbw/MjmIZ6U8Z86uDVVBP0pf
         x5Cv3+0amXap+7Ma1uHNXUr/cFzuiu5kqRYV5oLF7fXU0aPRFkmutlMahGF6J0LMoX1a
         sHSitE//r2u1ka/DOOhPeSq+fVkfKrNsfyGtpJgmRxcIwJ3wfopqpPslGDBVHcTNqD6E
         HquWznekc9NiICwuz2mglhG4jpWUZpSu6ojrRTDAkQesVD4alnUNwAwrE2Cc6k1yocwW
         FyOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Lua8D0OE;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 18si1248576pfy.280.2019.05.29.15.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 15:44:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Lua8D0OE;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 47F55242B7;
	Wed, 29 May 2019 22:44:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559169865;
	bh=aKHSIkDbzxATBUyOwATnE+u9n6O5//MnT+XxsgiEgMw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Lua8D0OEdQGWNihWIIxnwi8g2DSd4p3FPHXUy/wPDm2mJJFGtr9iud1QVtqcVZ6nY
	 JjU1tC6/svRlClz2RLkeEg487A1MsvGqcAmQhInkA6731FKKDXGUVB4BtZZvHthQLM
	 YtliyN5/GyYmIF4EAyFC4b2Zxh+Ilh06OTNDKszc=
Date: Wed, 29 May 2019 15:44:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Qian Cai <cai@lca.pw>
Cc: axboe@kernel.dk, hch@lst.de, peterz@infradead.org, oleg@redhat.com,
 gkohli@codeaurora.org, mingo@redhat.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/page_io: fix a crash in do_task_dead()
Message-Id: <20190529154424.c0fe2758cf5af42ff258714a@linux-foundation.org>
In-Reply-To: <1559156813-30681-1-git-send-email-cai@lca.pw>
References: <1559156813-30681-1-git-send-email-cai@lca.pw>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 May 2019 15:06:53 -0400 Qian Cai <cai@lca.pw> wrote:

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

Nice description, thanks.

And...  ouch.  blk_wake_io_task() is a scary thing - changing a task to
TASK_RUNNING state from interrupt context.  I wonder whether the
assumptions which that is making hold true in all situations even after
this change.

Is polled block IO important enough for doing this stuff?

> Fixes: 0619317ff8ba ("block: add polled wakeup task helper")

That will be needing a cc:stable, no?

> ...
>
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -140,7 +140,8 @@ static void end_swap_bio_read(struct bio *bio)
>  	unlock_page(page);
>  	WRITE_ONCE(bio->bi_private, NULL);
>  	bio_put(bio);
> -	blk_wake_io_task(waiter);
> +	/* end_swap_bio_read() could be called from an interrupt handler. */
> +	wake_up_process(waiter);
>  	put_task_struct(waiter);
>  }

