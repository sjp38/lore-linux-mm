Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07327C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:40:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8A8020645
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:40:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="HbHibLcx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8A8020645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4BB98E0143; Fri, 22 Feb 2019 17:40:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFA528E0141; Fri, 22 Feb 2019 17:40:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC28C8E0143; Fri, 22 Feb 2019 17:40:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91B6A8E0141
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 17:40:16 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id x9so3218346ite.1
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:40:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=r5Zyr386b7jk621VkWpXMjOaEfMie198787q47pcEnM=;
        b=GzdsTX8oRz5/kxY8Q1QB3/V3gAEBCv2r/B0sQ4OOny04IV89zX43DKk96IEj4bkgX1
         aoQrxhS8TfB5iFK3PqKBIBKX1dMZf8xhMDJHvHzTQJlW8u+L+0ZMr1yt7OKPxUs/eDvx
         D9ygh/aHqYZWF3SfJUiczTP1wHuYRjgZKSA+VpTOZNUsgmYLer8rB/Z3PthBj8ejKs4W
         ZTJbE2WKRFSdbd5XI/hGgCGmXCv8M8Gz5aQvce0dKpHBPCmBLtb3wG0N9SVFZVkxkGZG
         vJJ9yZCNuA9b0sVaRl/jBq9dhWdRRzrXBfCcM6ofpeFLjBN6BeeLFSw1ZqfIS3Gao3Di
         45uw==
X-Gm-Message-State: AHQUAuagBjW0la/H3QnM0ukuCHFRAbMoXKJPA3AP7V7TI9wVpsTqIPOd
	PT/P4tCyI6dc2wxuV/kyJfRHYYiaygYDDRsxxKrj/8BooXJOLh5FAdlHmYxn7BjqOjmbqYyinXa
	lndPj4R/dDzI8hhLjTHLjCdrj1gCYUmGuL3PyXshCuWqme/WJRcOzHaLNCJ979PvN8CLNin93Nd
	8w62LnJOJ10k1WXkHkvAW6/XtzNAQfY37GL/CJ8EeYczRczNy0+95anFRDaRpwX320rPXJcGmeW
	PfQsZ7X0ZdAmKcVtQbv8CjovJfSlkYZRpJwaIgnJPS7mHiN32aS72VzGCfxWTVx60fbscDNiIWB
	Qsi+/wwtbjI7SqwyLw3dBVF9RQIfcdDONCrPa+wcCr+XAstvTBhYPcVudvq0kDLc9XDEdVeBhzA
	Y
X-Received: by 2002:a24:4211:: with SMTP id i17mr4013796itb.157.1550875216373;
        Fri, 22 Feb 2019 14:40:16 -0800 (PST)
X-Received: by 2002:a24:4211:: with SMTP id i17mr4013765itb.157.1550875215461;
        Fri, 22 Feb 2019 14:40:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550875215; cv=none;
        d=google.com; s=arc-20160816;
        b=y9+cjcap+yxrisx88qAYBpvnUIyxB6AcdCqAb6uREBoPK6J+Y0XVjfDRjqt2EnWiNU
         YHdZZDX5Sbt75AVoF8UlAcdQ55OCcwHUMSJoDiW1BOEiq5ATUTWxfibtiDnWfuMB5M5C
         l/jLFRi28YRbMLHthEDJCoOA006fxn4fFaWaEuTeV9r1sDamzaco1FDLIMC/NY6qBfuF
         pLZdm1//Wrhnez+kORoHYNUtCy/ibLG3ssd++V8L9Jv44fKlJh13KKMerm+w/nh3LjD+
         n7+50IzXbVTdf+OnjfHjgIZKUDRL/1SceG4paBHEOr4eZmN5ttrE/k0CcGljkKGuYJUI
         9AbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=r5Zyr386b7jk621VkWpXMjOaEfMie198787q47pcEnM=;
        b=oEBb+XSOQ1hBTlZwXB9ldjg1Ul4OX4p0dCRp3pP6U7FeJrGk12XaLnXkoGISLHHIKy
         OyBBfEbgm06gw+P2fz4uy9BTxKoi+uO11A7N5VKk9yV6tFK2N8P6bp1L+EfMVgCduxZX
         HtgaMnd2B7uoPg4G1KZ8o2UjIseTDq/Y+DEj8eEOt7hobqCkrA25ITq6eaNjilJ/MQBe
         BypRiU69aGp0+wzUUQRgf9qJU5CU5Oa4Gpht4Fha+xIHPXVu5Loz+d8Ktjg5Q53apmH2
         J8+73ET3oIy7BAowA/HLOTyfni406zQ4bqSSV1HBKyvokv6GmL+LPPhvhvF8rVRqjbEh
         5gDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=HbHibLcx;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.41 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x17sor1525845iog.24.2019.02.22.14.40.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 14:40:15 -0800 (PST)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=HbHibLcx;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.41 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=r5Zyr386b7jk621VkWpXMjOaEfMie198787q47pcEnM=;
        b=HbHibLcxI4Fm/sA7Me0oZMOKBt3DBOt41H2ngTU64GnBRu0TNEa8fXa4Tu2T9K8KUr
         mfIRnZlwzOoVF6hbLRYIjTa+fudwydJ4VYVHXCOK7Jjk8Br7Bg+GT+KKs5s3E28/aHfu
         Bf4IBuscavU9fN8SeA5xn+SoF0YP+4/ZVidAomH9pxRKv655L0b1X0H2ONMYiBflSa1g
         8nlWC8b5L47oT6OsSWiLzxAkk5WB1mRTErQtBwRie3hiSVDL3pxmuo1GAh7dbYi+gfa/
         wpSdSuTY7J8LuF04kkm4Ky6PCB5bXZjGRky0PrEJ+Bk+rZWdn25ES5yoAF5+Ou1R1vVw
         5g5Q==
X-Google-Smtp-Source: AHgI3IaAwxYR+AbLBr7aIm6Es0df9t4IpdfSMQ3gSxZjyr6YyUp4xE3ZOiX2iB3fanFIGsBKiQiPsA==
X-Received: by 2002:a6b:d904:: with SMTP id r4mr3425982ioc.98.1550875214456;
        Fri, 22 Feb 2019 14:40:14 -0800 (PST)
Received: from [172.19.131.32] ([8.46.76.24])
        by smtp.gmail.com with ESMTPSA id v5sm1115216iof.39.2019.02.22.14.40.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 14:40:13 -0800 (PST)
Subject: Re: io_submit with slab free object overwritten
To: Qian Cai <cai@lca.pw>
Cc: viro@zeniv.linux.org.uk, hare@suse.com, bcrl@kvack.org,
 linux-aio@kvack.org, Linux-MM <linux-mm@kvack.org>
References: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <cd3bac6a-02b2-351e-3f81-322c2e0ca03e@kernel.dk>
Date: Fri, 22 Feb 2019 15:40:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/21/19 10:40 PM, Qian Cai wrote:
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
> [23424.121250]  generic_make_request+0x220/0x510
> [23424.121254]  submit_bio+0xc8/0x1f0
> [23424.121256]  blkdev_direct_IO+0x36c/0x610
> [23424.121260]  generic_file_read_iter+0xbc/0x230
> [23424.121263]  blkdev_read_iter+0x50/0x80
> [23424.121266]  aio_read+0x138/0x200
> [23424.121269]  io_submit_one+0x7c4/0xb20
> [23424.121272]  sys_io_submit+0xe0/0x350
> [23424.121275]  system_call+0x5c/0x70
> [23424.121278] INFO: Slab 0x00000000841158ec objects=85 used=85 fp=0x
> (null) flags=0x13fffc000000200
> [23424.121282] INFO: Object 0x000000007e677ed8 @offset=5504 fp=0x00000000e42bdf6f
> [23424.121282]
> [23424.121287] Redzone 000000005483b8fc: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121291] Redzone 00000000b842fe53: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121295] Redzone 00000000deb0d052: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121299] Redzone 0000000014045233: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121302] Redzone 00000000dd5d6c16: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121306] Redzone 00000000538b5478: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121310] Redzone 000000001f7fb704: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121314] Redzone 0000000000e0484d: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121318] Object 000000007e677ed8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121322] Object 00000000e207f30b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121326] Object 00000000a7a45634: 6b 6b 6b 6b 6b 6b 6b 6b ff ff ff ff 6b
> 6b 6b 6b  kkkkkkkk....kkkk
> [23424.121330] Object 00000000c85d951d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121334] Object 000000003104522f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121338] Object 00000000cfcdd820: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121342] Object 00000000dded4924: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121346] Object 00000000ff6687a4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121350] Object 00000000df3d67f6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121354] Object 00000000ddc188d1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121358] Object 000000002cee751a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121362] Object 00000000a994f007: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b a5  kkkkkkkkkkkkkkk.
> [23424.121366] Redzone 000000009f3d62e2: bb bb bb bb bb bb bb bb
>          ........
> [23424.121370] Padding 00000000e5ccead8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121374] Padding 000000002b0c1778: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121378] Padding 00000000c67656c7: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121382] Padding 0000000078348c5a: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121386] Padding 00000000f3297820: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121390] Padding 00000000e55789f4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121394] Padding 00000000d0fbb94c: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121397] Padding 00000000bcb27a87: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121743] CPU: 7 PID: 12174 Comm: vgs Tainted: G    B   W    L
> 5.0.0-rc7-next-20190221+ #7
> [23424.121758] Call Trace:
> [23424.121762] [c0000004ce5bf7b0] [c0000000007deb8c] dump_stack+0xb0/0xf4
> (unreliable)
> [23424.121770] [c0000004ce5bf7f0] [c00000000037d310] print_trailer+0x250/0x278
> [23424.121775] [c0000004ce5bf880] [c00000000036d578]
> check_bytes_and_report+0x138/0x160
> [23424.121779] [c0000004ce5bf920] [c00000000036fac8] check_object+0x348/0x3e0
> [23424.121784] [c0000004ce5bf990] [c00000000036fd18]
> alloc_debug_processing+0x1b8/0x2c0
> [23424.121788] [c0000004ce5bfa30] [c000000000372d14] ___slab_alloc+0xbb4/0xfa0
> [23424.121792] [c0000004ce5bfb60] [c000000000373134] __slab_alloc+0x34/0x60
> [23424.121802] [c0000004ce5bfb90] [c000000000373664] kmem_cache_alloc+0x504/0x5c0
> [23424.121812] [c0000004ce5bfc20] [c000000000476a9c] io_submit_one+0x9c/0xb20
> [23424.121824] [c0000004ce5bfd50] [c000000000477f10] sys_io_submit+0xe0/0x350
> [23424.121832] [c0000004ce5bfe20] [c00000000000b000] system_call+0x5c/0x70
> [23424.121836] FIX aio_kiocb: Restoring 0x000000009f1f5145-0x00000000841e301b=0x6b
> [23424.121836]
> [23424.121840] FIX aio_kiocb: Marking all objects used

Can you try this one? We only need to write it for polled, and for polled
the caller is the one that will reap the iocb. Hence it's safe to write
it after submission if we are marked polled.


diff --git a/fs/block_dev.c b/fs/block_dev.c
index 0e3155e817cc..f78fc7bf2225 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -419,11 +419,17 @@ __blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, int nr_pages)
 
 		nr_pages = iov_iter_npages(iter, BIO_MAX_PAGES);
 		if (!nr_pages) {
-			if (iocb->ki_flags & IOCB_HIPRI)
+			bool polled = false;
+
+			if (iocb->ki_flags & IOCB_HIPRI) {
 				bio_set_polled(bio, iocb);
+				polled = true;
+			}
 
 			qc = submit_bio(bio);
-			WRITE_ONCE(iocb->ki_cookie, qc);
+
+			if (polled)
+				WRITE_ONCE(iocb->ki_cookie, qc);
 			break;
 		}
 

-- 
Jens Axboe

