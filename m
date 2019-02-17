Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85BF2C10F06
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 13:14:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B0AD2192C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 13:14:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B0AD2192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D99788E0003; Sun, 17 Feb 2019 08:14:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D49A78E0001; Sun, 17 Feb 2019 08:14:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C39828E0003; Sun, 17 Feb 2019 08:14:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 976C48E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 08:14:04 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id q15so12667776qki.14
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 05:14:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nu5bMcxmsm7ufZa+1SEfKKyDFAUuY7anUqaD0T/wDuo=;
        b=GjE3dTcalF4EB0uc+RqER1XJc6AOTUcnC3L60dPvM5H4Ks4koNvAxUPIay2mAzkYCC
         b6TyJIYDKUyBKEYL+bnxggI8LDvxiqtBAbAiv3+EohHBeRtakoiL0ECTssqvIb4ZX6YX
         6O9swVuq5epdQ1o3L4CQnzonHAbBjvSpWtTfFY1BsrJlz9/HnNeBUfmFzUEQf8foE5TN
         58I2npkJUW4EvcR7IgOxGiW7y1dHDU9zJoxNnpWobi5uUclfdBEwSZJa3psz240NfPLD
         /b/5vYyFbcSXOPQdGlFW6AA98RMExsFsBs8VqevVpfoMWnUPJ3/fScG5XKIaXSLEknYf
         Z2pw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaLbrx3EKzju6OoUAUuWEwljPVteGP/pk2bsdeeltS+aPHNAkgY
	hfoq7/gWVjKQL4238aVW7LwWa4sZ5CD5mLoLoG26Yg2Ux3iLNktDT5wm7urIn/D892//s2BpMqW
	J+LIVyGnismZbBRqynkeYbJJPgCebNPJbNMsX/8KrTQAeXx1zw4M6banUYrkxy089cg==
X-Received: by 2002:a37:8546:: with SMTP id h67mr13421285qkd.277.1550409244368;
        Sun, 17 Feb 2019 05:14:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaykqujHuIsc42a1pz3BQER+PtdOLUUaAuhSLQFeU+edJni/UeG7S6g3ZXq3lb70CgvaqSH
X-Received: by 2002:a37:8546:: with SMTP id h67mr13421259qkd.277.1550409243813;
        Sun, 17 Feb 2019 05:14:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550409243; cv=none;
        d=google.com; s=arc-20160816;
        b=PyHq/wO7qNTGTVAGbSLamsoiqY3+jxnGCDPUMURi96IJRprBBoiqhT/KaE2deuqNG6
         OWU/1QBn0pUo9DQqsMtlINkSZ4pIfh7XUswWIGEeRc3KIGQSP0oXnwKq7GGcwUojABNU
         HYZTqFcAls7mfSyfOhF+psjBIJuASrqP0cJqklBx0MXJ7wLqp3TsqujRW076CGn6V1qy
         zx/Cu3OtQ76Y2hCP2u0DJly9s6idJjnl6Kbh1qonPvTG+n+wsnKv4bVaKJ2/Tt1OKGeQ
         zPPinc/Hf3grURGZFZtbKW00QCAexcyq0f9X0ZcTYV8QbjpU2uTN4csNO7FSpFdBfrX3
         Yvxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nu5bMcxmsm7ufZa+1SEfKKyDFAUuY7anUqaD0T/wDuo=;
        b=VcbSVQExGlgEiaFKUE0qw6oHR9KMf3p7AQKLUOjFRjzi4NQV6VsGQUHf2yjpqk/hqg
         dsi9ujc0FeTeHR1brGato2uEMBthD1tf671RPeprqzzLPwz1fczrDBO3Bxe7s9ItnWcV
         2rLu/jIMlsAM17RnM9zbm8Nfo70lQM3jIxnCKHwafESwCPHW2J/qkQOwoL9I2dQc1DI1
         xRUPDey7Qj056grKlAjM7dz0iYApURfIRyS4gsmBxyXQIgtB39sbk2LDRa1ISmeM9b9W
         YwW6a++RJI+j6ryjHe+5P0eSEV+Rn4fIIdA4BWcDh8B/29XyiMK0mfAzOfK8ussBTWtv
         AgBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l18si6809763qkk.192.2019.02.17.05.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Feb 2019 05:14:03 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AD99281DF0;
	Sun, 17 Feb 2019 13:14:02 +0000 (UTC)
Received: from ming.t460p (ovpn-8-16.pek2.redhat.com [10.72.8.16])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5679760BF7;
	Sun, 17 Feb 2019 13:13:37 +0000 (UTC)
Date: Sun, 17 Feb 2019 21:13:33 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Jens Axboe <axboe@kernel.dk>
Cc: Bart Van Assche <bvanassche@acm.org>, Mike Snitzer <snitzer@redhat.com>,
	linux-mm@kvack.org, dm-devel@redhat.com,
	Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Omar Sandoval <osandov@fb.com>, cluster-devel@redhat.com,
	linux-ext4@vger.kernel.org,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Boaz Harrosh <ooo@electrozaur.com>,
	Gao Xiang <gaoxiang25@huawei.com>, Coly Li <colyli@suse.de>,
	linux-raid@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>,
	linux-bcache@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Dave Chinner <dchinner@redhat.com>, David Sterba <dsterba@suse.com>,
	linux-block@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [dm-devel] [PATCH V15 00/18] block: support multi-page bvec
Message-ID: <20190217131332.GC7296@ming.t460p>
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <c52b6a8b-d1d4-67ff-f81c-371d09cc6d5b@kernel.dk>
 <1550250855.31902.102.camel@acm.org>
 <18c711a9-ca13-885d-43cd-4d48e683a6a2@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18c711a9-ca13-885d-43cd-4d48e683a6a2@kernel.dk>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Sun, 17 Feb 2019 13:14:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 10:59:47AM -0700, Jens Axboe wrote:
> On 2/15/19 10:14 AM, Bart Van Assche wrote:
> > On Fri, 2019-02-15 at 08:49 -0700, Jens Axboe wrote:
> >> On 2/15/19 4:13 AM, Ming Lei wrote:
> >>> This patchset brings multi-page bvec into block layer:
> >>
> >> Applied, thanks Ming. Let's hope it sticks!
> > 
> > Hi Jens and Ming,
> > 
> > Test nvmeof-mp/002 fails with Jens' for-next branch from this morning.
> > I have not yet tried to figure out which patch introduced the failure.
> > Anyway, this is what I see in the kernel log for test nvmeof-mp/002:
> > 
> > [  475.611363] BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
> > [  475.621188] #PF error: [normal kernel read fault]
> > [  475.623148] PGD 0 P4D 0  
> > [  475.624737] Oops: 0000 [#1] PREEMPT SMP KASAN
> > [  475.626628] CPU: 1 PID: 277 Comm: kworker/1:1H Tainted: G    B             5.0.0-rc6-dbg+ #1
> > [  475.630232] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> > [  475.633855] Workqueue: kblockd blk_mq_requeue_work
> > [  475.635777] RIP: 0010:__blk_recalc_rq_segments+0xbe/0x590
> > [  475.670948] Call Trace:
> > [  475.693515]  blk_recalc_rq_segments+0x2f/0x50
> > [  475.695081]  blk_insert_cloned_request+0xbb/0x1c0
> > [  475.701142]  dm_mq_queue_rq+0x3d1/0x770
> > [  475.707225]  blk_mq_dispatch_rq_list+0x5fc/0xb10
> > [  475.717137]  blk_mq_sched_dispatch_requests+0x256/0x300
> > [  475.721767]  __blk_mq_run_hw_queue+0xd6/0x180
> > [  475.725920]  __blk_mq_delay_run_hw_queue+0x25c/0x290
> > [  475.727480]  blk_mq_run_hw_queue+0x119/0x1b0
> > [  475.732019]  blk_mq_run_hw_queues+0x7b/0xa0
> > [  475.733468]  blk_mq_requeue_work+0x2cb/0x300
> > [  475.736473]  process_one_work+0x4f1/0xa40
> > [  475.739424]  worker_thread+0x67/0x5b0
> > [  475.741751]  kthread+0x1cf/0x1f0
> > [  475.746034]  ret_from_fork+0x24/0x30
> > 
> > (gdb) list *(__blk_recalc_rq_segments+0xbe)
> > 0xffffffff816a152e is in __blk_recalc_rq_segments (block/blk-merge.c:366).
> > 361                                                  struct bio *bio)
> > 362     {
> > 363             struct bio_vec bv, bvprv = { NULL };
> > 364             int prev = 0;
> > 365             unsigned int seg_size, nr_phys_segs;
> > 366             unsigned front_seg_size = bio->bi_seg_front_size;
> > 367             struct bio *fbio, *bbio;
> > 368             struct bvec_iter iter;
> > 369
> > 370             if (!bio)
> 
> Just ran a few tests, and it also seems to cause about a 5% regression
> in per-core IOPS throughput. Prior to this work, I could get 1620K 4k
> rand read IOPS out of core, now I'm at ~1535K. The cycler stealer seems
> to be blk_queue_split() and blk_rq_map_sg().

Could you share us your test setting?

I will run null_blk first and see if it can be reproduced.

Thanks,
Ming

