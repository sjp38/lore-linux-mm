Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EA55C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:25:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65ED92070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:25:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65ED92070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00FCB8E0137; Fri, 22 Feb 2019 17:25:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFFE18E0142; Fri, 22 Feb 2019 17:25:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEE9C8E0137; Fri, 22 Feb 2019 17:25:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id B22A68E0141
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 17:25:49 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a11so2698501qkk.10
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:25:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=C7HicXx1VRXVkGmpmTQCDneWMjM3tiNY4mXRVT/EbMM=;
        b=rSHEJh1IneQZxyf1GXHm5hBI9KVPzsP56+Jw08kBcufqiva3zAGCj5Ut2omw4FcXrW
         4dNvWjJlPHoKDLMZCkbqpWtP45oY+P4wk6RFBOirrWTJwezwH2S5x4tsuqO2zx0hWv0z
         vsOtp/H5oZlJNKfw0U6PIjxuqDDsgHN5WzvC1FvGp/So1zVd5dVoF0dNU69UuPRvdafi
         q0Vf6b74kwTfBk9a9PlYnW4qdpRTk/PRd/juLHkRh0pPKppfTZbRSfGvnpyfFwROP0vC
         8RlWi5LrH8nKk0hL6a50QD+RhdsIgautmNSVqFZqhawuHLHoBaXwAwAumR9kjadlA1jI
         V5Aw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua2pucnlQpgLOIrVT1jl5bohXaNDQxILgoRGUMMJXxd1aRQfUbC
	el9NrmH3T9YMlhRTx4L9Gqaw8DPirUdpcdI+wr/+0kerxIfVuGZ40NKVugKu0YonED0DVvP8sml
	XmxZRknOkE0TxbKFydThqG7MCOqWGbdsu/kInbtQSmCftEyC/uHfFX1/to7PazP8Vpg==
X-Received: by 2002:ac8:554d:: with SMTP id o13mr5029998qtr.105.1550874349508;
        Fri, 22 Feb 2019 14:25:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQodBnxGupjOqEf4Ix7uwyhAZdci8OAksMHqrmx5JFiuZj2JdcNe06u1VjNEma7U9UPwes
X-Received: by 2002:ac8:554d:: with SMTP id o13mr5029968qtr.105.1550874348894;
        Fri, 22 Feb 2019 14:25:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550874348; cv=none;
        d=google.com; s=arc-20160816;
        b=BGZGbVg+g3VQvwPdGO9S2rXcjK4jSiz57ijNepT9UgK0zOqeX/iRoSRxJg3ZxB5wBI
         pA8xBmLWcvYTIcM0al5OhxEZfbYJ7zs83PHzEirCZS7kiX35lamR/ZG9InrPwNxHmKxp
         nQsCgw16U6O/1cKcWoOmvuXdHgfIbUHbfIryOX8JmlPgS4+ptkZgA3pcvmLsrCZWazCl
         uEBNWwQ+AqS/Vcs14b+gDNKCZPfVSGXV74fDWYrdINFiO6hwslP66bx9tdwjWPzF9kvX
         1By+B03cAJci0fNgn65LoxxlYnMrxfYvUzoWKxc0W3oVAnod7mw9rjS7gDjVSufjF4oi
         TauA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=C7HicXx1VRXVkGmpmTQCDneWMjM3tiNY4mXRVT/EbMM=;
        b=0UN9hMmSnW6/AWxYyMhbFvlw+KZxxM+7rJlvrp00iiosGGvOKuAwWcCIZMbaP/oCzW
         BkY/tK4IHi8hsv979JdijRmjBPU3hBEEbzvF9rbAtcSXIUh6RSars0J7N+FfFrTvW7bT
         waC1M2FlS+16Rjz0GrCwmWpzx8PXvXZ4WvxJPnZPWQiNJD/CNyuAd4QJfbXq00qg/rHq
         1fPnaG7HY+q9T2QvpO/tUcmUVhnJw/NjQ4YQ2lwjHoX0E4w4spmsbadJeddmjzta0mj+
         uP4pIe3N5PlH/3kg0h3FgTLrwbN7OPZ3f2aSoA7nYFMAO07ATtby3qfOR2/q7xQGFWar
         rEGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q15si1845715qtf.167.2019.02.22.14.25.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 14:25:48 -0800 (PST)
Received-SPF: pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D9C37883BA;
	Fri, 22 Feb 2019 22:25:47 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D63F95D704;
	Fri, 22 Feb 2019 22:25:46 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: Qian Cai <cai@lca.pw>
Cc: axboe@kernel.dk,  viro@zeniv.linux.org.uk,  hare@suse.com,  bcrl@kvack.org,  linux-aio@kvack.org,  Linux-MM <linux-mm@kvack.org>
Subject: Re: io_submit with slab free object overwritten
References: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Fri, 22 Feb 2019 17:25:46 -0500
In-Reply-To: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw> (Qian Cai's message
	of "Fri, 22 Feb 2019 00:40:29 -0500")
Message-ID: <x49o973v4t1.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 22 Feb 2019 22:25:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Qian Cai <cai@lca.pw> writes:

> This is only reproducible on linux-next (20190221), as v5.0-rc7 is fine. Running
> two LTP tests and then reboot will trigger this on ppc64le (CONFIG_IO_URING=n
> and CONFIG_SHUFFLE_PAGE_ALLOCATOR=y).
>
> # fgetxattr02
> # io_submit01
> # systemctl reboot
>
> There is a 32-bit (with all ones) overwritten of free slab objects (poisoned).
>
> [23424.121182] BUG aio_kiocb (Tainted: G    B   W    L   ): Poison overwritten
> [23424.121189]
> -----------------------------------------------------------------------------
> [23424.121189]
> [23424.121197] INFO: 0x000000009f1f5145-0x00000000841e301b. First byte 0xff
> instead of 0x6b
> [23424.121205] INFO: Allocated in io_submit_one+0x9c/0xb20 age=0 cpu=7 pid=12174
> [23424.121212]  __slab_alloc+0x34/0x60
> [23424.121217]  kmem_cache_alloc+0x504/0x5c0
> [23424.121221]  io_submit_one+0x9c/0xb20
> [23424.121224]  sys_io_submit+0xe0/0x350
> [23424.121227]  system_call+0x5c/0x70
> [23424.121231] INFO: Freed in aio_complete+0x31c/0x410 age=0 cpu=7 pid=12174
> [23424.121234]  kmem_cache_free+0x4bc/0x540
> [23424.121237]  aio_complete+0x31c/0x410
> [23424.121240]  blkdev_bio_end_io+0x238/0x3e0
> [23424.121243]  bio_endio.part.3+0x214/0x330
> [23424.121247]  brd_make_request+0x2d8/0x314 [brd]

Yeah, the ramdisk is synchronous, so I/O completes in the issuing
context.  I guess we could also see a problem with an error in the issue
path, and regular storage.

That -1 probably comes from this:

@@ -412,6 +420,7 @@ __blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, int nr_pages)
                                bio->bi_opf |= REQ_HIPRI;
 
                        qc = submit_bio(bio);
+                       WRITE_ONCE(iocb->ki_cookie, qc);

#define BLK_QC_T_NONE           -1U

Use after free.  Further down the function, we also reference the iocb,
though:

        if (!is_sync)
                return -EIOCBQUEUED;

        for (;;) {
                set_current_state(TASK_UNINTERRUPTIBLE);
                if (!READ_ONCE(dio->waiter))
                        break;

                if (!(iocb->ki_flags & IOCB_HIPRI) ||
                    !blk_poll(bdev_get_queue(bdev), qc, true))
                        io_schedule();
        }

So I guess a bit more auditing is required.

-Jeff

