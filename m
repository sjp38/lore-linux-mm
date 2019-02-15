Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30E8FC10F07
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBFB02190C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:14:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBFB02190C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=acm.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 666848E0002; Fri, 15 Feb 2019 12:14:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5ED508E0001; Fri, 15 Feb 2019 12:14:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B5658E0002; Fri, 15 Feb 2019 12:14:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03DA88E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:14:20 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q21so7921400pfi.17
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:14:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=V5tWVBuDkxTrLw/rJUGUbWNUGeClHnQKAfjUPFO5WHE=;
        b=OwyP4kjq2bVtaRTe6dhNy7Xr+4pxAi2OZAFnA+zaAdzsUq83WPXjJojFIsJ1YBtvGW
         cWipEGePKSWShSJFIYbvRxN8W+JaRW1MCEPTza/KpzNyOiJ61fqf+zu0Y7iz4B2aq2N4
         3CuSILnE3F2yc+VBtJFbMkMO/794fRvAL9aVBfonF2nRnDzBQXYEezekDYogkXPsd1zI
         cGKm7Gc2Vf+QSLR1c4KeW0QwbliNmEhWZjvd0n/UjiUDNghzmmyLZVuOkJk7C5K6oN9o
         xG8jmuh6M+mHyZZBG9Gboq1NebXqnLdDoG0t6qOXG310vyuxNLmXuIZLgalOypWgfe7a
         MXNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Gm-Message-State: AHQUAuaeam39gi0kNXiKYZxYeqkSwEtYQCAdF5sonT+Ta9qp1TecpLjx
	hKHW3NZW9ArkUeK92jbSEX4zKYNSQd0Aiw0kxtYhB6AaGTNP3NmHutHSeEhGg0l0k/+DUkHed3/
	Orq3r7r9mUJo0zUGgzOg1Ma97jmh+/Xs+BNZ1ljqYp2mfU77slGJEK6rT6OqFXXD2ZRmMUk5+bW
	cTCyonfvuMmgRKgW/InKF211tT8ny45FQGob9zRfOnx78IrgO+V2GhKSfb/Z6QFjjzY3nUfHy9Y
	K3tKZehhUzdC0L94oy4QptEUcP8+KYQiK5AHWrHjCvvvbIGymXwP6DgKoAVJjB+0E2WlpryOzbr
	JsytD9ktZHPLExcbz7xcG+rmhY6+vo/C4t+d4geK0LHUgAc8oGefqZ5p4i2nwQYRnUcC2U/1+w=
	=
X-Received: by 2002:a62:3603:: with SMTP id d3mr11161789pfa.146.1550250859413;
        Fri, 15 Feb 2019 09:14:19 -0800 (PST)
X-Received: by 2002:a62:3603:: with SMTP id d3mr11161706pfa.146.1550250858638;
        Fri, 15 Feb 2019 09:14:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250858; cv=none;
        d=google.com; s=arc-20160816;
        b=ZeNzz+QSQ8t3SL/3xvEpCg684VGMUfgt8j0r7YG4JVI6RnwmiVAtZ08FkvdQ6uqdzY
         lcR92SQJBK6/LwgjY2ZhhllOeUpuYSQs6gah+1YUUIDY8e82j5QIscSNw0IwGGsP7k6X
         /QFgIWevw1slW7Tt1BqwJZ9GKmYEJ5YeMvzHYi2MKJ7SDeNyFhK8aKbudNaJqCUH9oJ8
         ftqlwJ7z4obnTsn2CZYCndyVOr/ETTvPwWYVBMCUk8LcyFRIacNFGZ6v3/+oFqtAkV3v
         B8W1h8WMwptLSuGtMHhnpS2ZvuDXxhUbPaHTYwJIF1fUFA2PQlaBGa1ehx+zkh+vAF6T
         APRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=V5tWVBuDkxTrLw/rJUGUbWNUGeClHnQKAfjUPFO5WHE=;
        b=RytfG7WpddyBFGvnqukqn0JJvIfqliJayyV4DoOuX++KeKc04xumlRbKdZHfvHJ9Yf
         0M11FFS9vDfgl644yRV8aLw4+qNYu98P2O9iaeddBr0MsSQCNkjafoFOCVPYyt2ycAeC
         JeGqjbWkZZoxUM452hXkc4I4AunETeECTkLlTaq4l4ow1Ypm08ruRkeCfkD1ZONMqB6q
         Q/D6p9JE8z89VJGcOrNL/pFA9Ebu6ZWf6tcmBYcTwUCS54A1IC+E9Ud27AEz8F76QAOK
         YMtmsIcmJSWw/JRfhoOE3EYNf6QJSBKGlE4EJ6FSmPZXHw0V1SKjEUioxEi/QFkcTSpg
         lyGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l14sor9908714pfj.27.2019.02.15.09.14.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 09:14:18 -0800 (PST)
Received-SPF: pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Google-Smtp-Source: AHgI3IakANE5EyG398yqtL0es6DsKhHFktstbAeHxhopwBULRdY+290B+ab/EnoU457BzmwQyumWvw==
X-Received: by 2002:aa7:8508:: with SMTP id v8mr10806465pfn.14.1550250857939;
        Fri, 15 Feb 2019 09:14:17 -0800 (PST)
Received: from ?IPv6:2620:15c:2cd:203:5cdc:422c:7b28:ebb5? ([2620:15c:2cd:203:5cdc:422c:7b28:ebb5])
        by smtp.gmail.com with ESMTPSA id e123sm14502265pgc.14.2019.02.15.09.14.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 09:14:16 -0800 (PST)
Message-ID: <1550250855.31902.102.camel@acm.org>
Subject: Re: [dm-devel] [PATCH V15 00/18] block: support multi-page bvec
From: Bart Van Assche <bvanassche@acm.org>
To: Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>, linux-mm@kvack.org,
 dm-devel@redhat.com,  Christoph Hellwig <hch@lst.de>, Sagi Grimberg
 <sagi@grimberg.me>, "Darrick J . Wong" <darrick.wong@oracle.com>, Omar
 Sandoval <osandov@fb.com>,  cluster-devel@redhat.com,
 linux-ext4@vger.kernel.org, Kent Overstreet <kent.overstreet@gmail.com>,
 Boaz Harrosh <ooo@electrozaur.com>, Gao Xiang <gaoxiang25@huawei.com>, Coly
 Li <colyli@suse.de>, linux-raid@vger.kernel.org,  Bob Peterson
 <rpeterso@redhat.com>, linux-bcache@vger.kernel.org, Alexander Viro
 <viro@zeniv.linux.org.uk>,  Dave Chinner <dchinner@redhat.com>, David
 Sterba <dsterba@suse.com>, linux-block@vger.kernel.org, Theodore Ts'o
 <tytso@mit.edu>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org
Date: Fri, 15 Feb 2019 09:14:15 -0800
In-Reply-To: <c52b6a8b-d1d4-67ff-f81c-371d09cc6d5b@kernel.dk>
References: <20190215111324.30129-1-ming.lei@redhat.com>
	 <c52b6a8b-d1d4-67ff-f81c-371d09cc6d5b@kernel.dk>
Content-Type: text/plain; charset="UTF-7"
X-Mailer: Evolution 3.26.2-1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-02-15 at 08:49 -0700, Jens Axboe wrote:
+AD4 On 2/15/19 4:13 AM, Ming Lei wrote:
+AD4 +AD4 This patchset brings multi-page bvec into block layer:
+AD4 
+AD4 Applied, thanks Ming. Let's hope it sticks+ACE

Hi Jens and Ming,

Test nvmeof-mp/002 fails with Jens' for-next branch from this morning.
I have not yet tried to figure out which patch introduced the failure.
Anyway, this is what I see in the kernel log for test nvmeof-mp/002:

+AFs  475.611363+AF0 BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
+AFs  475.621188+AF0 +ACM-PF error: +AFs-normal kernel read fault+AF0
+AFs  475.623148+AF0 PGD 0 P4D 0  
+AFs  475.624737+AF0 Oops: 0000 +AFsAIw-1+AF0 PREEMPT SMP KASAN
+AFs  475.626628+AF0 CPU: 1 PID: 277 Comm: kworker/1:1H Tainted: G    B             5.0.0-rc6-dbg+- +ACM-1
+AFs  475.630232+AF0 Hardware name: QEMU Standard PC (i440FX +- PIIX, 1996), BIOS 1.10.2-1 04/01/2014
+AFs  475.633855+AF0 Workqueue: kblockd blk+AF8-mq+AF8-requeue+AF8-work
+AFs  475.635777+AF0 RIP: 0010:+AF8AXw-blk+AF8-recalc+AF8-rq+AF8-segments+-0xbe/0x590
+AFs  475.670948+AF0 Call Trace:
+AFs  475.693515+AF0  blk+AF8-recalc+AF8-rq+AF8-segments+-0x2f/0x50
+AFs  475.695081+AF0  blk+AF8-insert+AF8-cloned+AF8-request+-0xbb/0x1c0
+AFs  475.701142+AF0  dm+AF8-mq+AF8-queue+AF8-rq+-0x3d1/0x770
+AFs  475.707225+AF0  blk+AF8-mq+AF8-dispatch+AF8-rq+AF8-list+-0x5fc/0xb10
+AFs  475.717137+AF0  blk+AF8-mq+AF8-sched+AF8-dispatch+AF8-requests+-0x256/0x300
+AFs  475.721767+AF0  +AF8AXw-blk+AF8-mq+AF8-run+AF8-hw+AF8-queue+-0xd6/0x180
+AFs  475.725920+AF0  +AF8AXw-blk+AF8-mq+AF8-delay+AF8-run+AF8-hw+AF8-queue+-0x25c/0x290
+AFs  475.727480+AF0  blk+AF8-mq+AF8-run+AF8-hw+AF8-queue+-0x119/0x1b0
+AFs  475.732019+AF0  blk+AF8-mq+AF8-run+AF8-hw+AF8-queues+-0x7b/0xa0
+AFs  475.733468+AF0  blk+AF8-mq+AF8-requeue+AF8-work+-0x2cb/0x300
+AFs  475.736473+AF0  process+AF8-one+AF8-work+-0x4f1/0xa40
+AFs  475.739424+AF0  worker+AF8-thread+-0x67/0x5b0
+AFs  475.741751+AF0  kthread+-0x1cf/0x1f0
+AFs  475.746034+AF0  ret+AF8-from+AF8-fork+-0x24/0x30

(gdb) list +ACo(+AF8AXw-blk+AF8-recalc+AF8-rq+AF8-segments+-0xbe)
0xffffffff816a152e is in +AF8AXw-blk+AF8-recalc+AF8-rq+AF8-segments (block/blk-merge.c:366).
361                                                  struct bio +ACo-bio)
362     +AHs
363             struct bio+AF8-vec bv, bvprv +AD0 +AHs NULL +AH0AOw
364             int prev +AD0 0+ADs
365             unsigned int seg+AF8-size, nr+AF8-phys+AF8-segs+ADs
366             unsigned front+AF8-seg+AF8-size +AD0 bio-+AD4-bi+AF8-seg+AF8-front+AF8-size+ADs
367             struct bio +ACo-fbio, +ACo-bbio+ADs
368             struct bvec+AF8-iter iter+ADs
369
370             if (+ACE-bio)

Bart.

