Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51FF5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 05:40:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA2A8207E0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 05:40:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="bsCv/zif"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA2A8207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 152FA8E00EE; Fri, 22 Feb 2019 00:40:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 125BE8E00ED; Fri, 22 Feb 2019 00:40:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F09528E00EF; Fri, 22 Feb 2019 00:40:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3DDE8E00EE
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 00:40:33 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 35so1158248qty.12
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 21:40:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:subject:to:cc:message-id
         :date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=4QJgJCZtxo4Y2NcbSVp9xBe5sX3FZcLo2gFUcbausxA=;
        b=uC/rLdXKf74yO6nFaGQsgCkdINwwZ0KYdjZcXUHMODN9fW7UVpiTHn0yNWtGa2OhER
         pZn8GaQXuN6IpOiQ7iUu3gZMpPuYugcR/spdWIUqRUiRPevwbNKB7HfV5CrMq8BhpXdp
         CwdfcALRD2DcvIRnaoP8WQ9t09aObfKxOWlgd4IH6AnqVrMWuMvu0qDO2mnlGSYkdM5j
         GaT2PEZV06C1mnHWxDcC6+0q0bYp2/ewE9bb/RdSxPM7ZI9kSVIjw1ubYSIwYCfXjrSM
         uXK32Zw9mFoWXkNA6OOkhMwpr3hoUtAMEXjRpWvMjuRUo3LitFXPxZZEYLYxBPKsX6ZT
         CZig==
X-Gm-Message-State: AHQUAubXo8qy/xPpF/7jczRHNCldG/1KZxowxkM+sirjhSgve8Ai5V9K
	zN+eAeISflCMsk7/veCkW5n4mYEFnj7vZ77QPQk41dhpmcGFzXAlDs0U6I+LcTVH2MSQJk7REhP
	VZzQyH32jaUKS32eB59KChWFhdDVkqCLmohm47LzO6ck90ZMTgi6bmV61kQvJG5qbttzOToMCDb
	oWyrrIx8d3fZ1IHGyq3HwD8wT7UVV2UdIqxDG09qyd8Qso8emjo0yG4obReLP+5q51i/AQ4cbeo
	dYUfmAwNt95dDg6HpSGfWsEeO8z/GsRj8GICPy4eXEXXycMlVJ3ATB0XCwWpfVJ/V23N0vPfoM+
	JOeJnmOtrhQ900mrlPb0eprwwN5UbQghhPjeIzi0JLzxP743yDgPsX4Yqqd9K2SxkEtSn+pm7XD
	j
X-Received: by 2002:ac8:2c92:: with SMTP id 18mr1678844qtw.269.1550814033481;
        Thu, 21 Feb 2019 21:40:33 -0800 (PST)
X-Received: by 2002:ac8:2c92:: with SMTP id 18mr1678809qtw.269.1550814032557;
        Thu, 21 Feb 2019 21:40:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550814032; cv=none;
        d=google.com; s=arc-20160816;
        b=V/hiUjlJhs5m8495JFyhwrYzqZZ4I7WIHYSKpAGMSPxQ1mI041aKyA6uenhaGV2/7J
         WcZ4Qg1ZghAuMX6xWx6HdmQNsokI7AEl4AizprQfJMnEvMVgeF9d+gMUuMe48M8UpkTO
         /y1O+xP13uc1LugHDSBmpPX9tQnESZwoiGrFUtbWaNdWWohKZULc90+DOzC/H3/EJRfw
         avFIRhZnNc39gXcWf2gnjQzJpy8FI6fA6YowkJcgq9E3ks/65AZFmu23ng7aIs87gHYJ
         xmFinpF1YYkmnWo8QIsFfuDfepygtWSDHY8Or2tkSfY7/hvzbuQAWPvUHHL0qBoueYwU
         WSWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:cc:to:subject:from:dkim-signature;
        bh=4QJgJCZtxo4Y2NcbSVp9xBe5sX3FZcLo2gFUcbausxA=;
        b=eYuZpqWOUpz6R9Nz/RHNOBKbSbkojEHdBAEamFOGysuTEQJbhxRNbSTonoab8EF9MP
         XTpKCUNq5n2+icZm98c0ElWkwpTtAHRJSCLB0i2e8DmRuNhpkWLszvpn7uVdE221JJNF
         MWzDliN/C6LRqylu58fEY4fX4V6Ds8ETZaqr6RQWKjjvfiPorXUxWnA7PQCbEqcKOTDQ
         0BK8IXFg2zyhjE5fsYn8TrAPRsz87mVjG8Ybc5KChVfRM1wf+DPxHcPmp3uIMoZjnrNl
         FfvyufemLxGRt1brbVmut7ZcW9SknPF3hx/K15kwvwFvS78/x57oFnoaPkZEDxcOFZ5O
         BA0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="bsCv/zif";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n28sor618078qtn.18.2019.02.21.21.40.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 21:40:32 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="bsCv/zif";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:subject:to:cc:message-id:date:user-agent:mime-version
         :content-language:content-transfer-encoding;
        bh=4QJgJCZtxo4Y2NcbSVp9xBe5sX3FZcLo2gFUcbausxA=;
        b=bsCv/zifuSwnrCCz8c5D3ihd2KbwGZ2y9kQBBp6usMSS6gV4LkhrR3OvevBy+n1/Ms
         pqhrabPPvSkVb/3oexWFGu8xZ/OjGM+McZOLDM77SnpE3wte1nCiGgb7yfg2l/a+svPD
         XHwczuaj/cOrly8CiR93fcFIWF06gJkqi2MXMW1LYYFxCgdu+rMYxyHOyTHg9dmq4jMu
         +b6jDd7/4xeZc7a93RObJlyLwcHlgE9uXNU9FdXNChrCpjKmH9PMXjd2dp4MGqUr21QA
         mXCt7tqWACX8J6eSQHENSYqcMPaRsKW6lV1vth8tAv5zvukvSMly7ebD/IoUKE3UG0Pa
         QusA==
X-Google-Smtp-Source: AHgI3IacwmlW+vOQ82PzIbOPMcSmg76AT3Kf5HuFPefaJ3DKwJP6zdvrKvBy9QH+KgaE5Zk/UsLlsw==
X-Received: by 2002:ac8:188d:: with SMTP id s13mr1779521qtj.256.1550814031611;
        Thu, 21 Feb 2019 21:40:31 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id k66sm310075qkc.25.2019.02.21.21.40.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 21:40:31 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: io_submit with slab free object overwritten
To: axboe@kernel.dk
Cc: viro@zeniv.linux.org.uk, hare@suse.com, bcrl@kvack.org,
 linux-aio@kvack.org, Linux-MM <linux-mm@kvack.org>
Message-ID: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
Date: Fri, 22 Feb 2019 00:40:29 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is only reproducible on linux-next (20190221), as v5.0-rc7 is fine. Running
two LTP tests and then reboot will trigger this on ppc64le (CONFIG_IO_URING=n
and CONFIG_SHUFFLE_PAGE_ALLOCATOR=y).

# fgetxattr02
# io_submit01
# systemctl reboot

There is a 32-bit (with all ones) overwritten of free slab objects (poisoned).

[23424.121182] BUG aio_kiocb (Tainted: G    B   W    L   ): Poison overwritten
[23424.121189]
-----------------------------------------------------------------------------
[23424.121189]
[23424.121197] INFO: 0x000000009f1f5145-0x00000000841e301b. First byte 0xff
instead of 0x6b
[23424.121205] INFO: Allocated in io_submit_one+0x9c/0xb20 age=0 cpu=7 pid=12174
[23424.121212]  __slab_alloc+0x34/0x60
[23424.121217]  kmem_cache_alloc+0x504/0x5c0
[23424.121221]  io_submit_one+0x9c/0xb20
[23424.121224]  sys_io_submit+0xe0/0x350
[23424.121227]  system_call+0x5c/0x70
[23424.121231] INFO: Freed in aio_complete+0x31c/0x410 age=0 cpu=7 pid=12174
[23424.121234]  kmem_cache_free+0x4bc/0x540
[23424.121237]  aio_complete+0x31c/0x410
[23424.121240]  blkdev_bio_end_io+0x238/0x3e0
[23424.121243]  bio_endio.part.3+0x214/0x330
[23424.121247]  brd_make_request+0x2d8/0x314 [brd]
[23424.121250]  generic_make_request+0x220/0x510
[23424.121254]  submit_bio+0xc8/0x1f0
[23424.121256]  blkdev_direct_IO+0x36c/0x610
[23424.121260]  generic_file_read_iter+0xbc/0x230
[23424.121263]  blkdev_read_iter+0x50/0x80
[23424.121266]  aio_read+0x138/0x200
[23424.121269]  io_submit_one+0x7c4/0xb20
[23424.121272]  sys_io_submit+0xe0/0x350
[23424.121275]  system_call+0x5c/0x70
[23424.121278] INFO: Slab 0x00000000841158ec objects=85 used=85 fp=0x
(null) flags=0x13fffc000000200
[23424.121282] INFO: Object 0x000000007e677ed8 @offset=5504 fp=0x00000000e42bdf6f
[23424.121282]
[23424.121287] Redzone 000000005483b8fc: bb bb bb bb bb bb bb bb bb bb bb bb bb
bb bb bb  ................
[23424.121291] Redzone 00000000b842fe53: bb bb bb bb bb bb bb bb bb bb bb bb bb
bb bb bb  ................
[23424.121295] Redzone 00000000deb0d052: bb bb bb bb bb bb bb bb bb bb bb bb bb
bb bb bb  ................
[23424.121299] Redzone 0000000014045233: bb bb bb bb bb bb bb bb bb bb bb bb bb
bb bb bb  ................
[23424.121302] Redzone 00000000dd5d6c16: bb bb bb bb bb bb bb bb bb bb bb bb bb
bb bb bb  ................
[23424.121306] Redzone 00000000538b5478: bb bb bb bb bb bb bb bb bb bb bb bb bb
bb bb bb  ................
[23424.121310] Redzone 000000001f7fb704: bb bb bb bb bb bb bb bb bb bb bb bb bb
bb bb bb  ................
[23424.121314] Redzone 0000000000e0484d: bb bb bb bb bb bb bb bb bb bb bb bb bb
bb bb bb  ................
[23424.121318] Object 000000007e677ed8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[23424.121322] Object 00000000e207f30b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[23424.121326] Object 00000000a7a45634: 6b 6b 6b 6b 6b 6b 6b 6b ff ff ff ff 6b
6b 6b 6b  kkkkkkkk....kkkk
[23424.121330] Object 00000000c85d951d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[23424.121334] Object 000000003104522f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[23424.121338] Object 00000000cfcdd820: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[23424.121342] Object 00000000dded4924: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[23424.121346] Object 00000000ff6687a4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[23424.121350] Object 00000000df3d67f6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[23424.121354] Object 00000000ddc188d1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[23424.121358] Object 000000002cee751a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b  kkkkkkkkkkkkkkkk
[23424.121362] Object 00000000a994f007: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b a5  kkkkkkkkkkkkkkk.
[23424.121366] Redzone 000000009f3d62e2: bb bb bb bb bb bb bb bb
         ........
[23424.121370] Padding 00000000e5ccead8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a  ZZZZZZZZZZZZZZZZ
[23424.121374] Padding 000000002b0c1778: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a  ZZZZZZZZZZZZZZZZ
[23424.121378] Padding 00000000c67656c7: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a  ZZZZZZZZZZZZZZZZ
[23424.121382] Padding 0000000078348c5a: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a  ZZZZZZZZZZZZZZZZ
[23424.121386] Padding 00000000f3297820: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a  ZZZZZZZZZZZZZZZZ
[23424.121390] Padding 00000000e55789f4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a  ZZZZZZZZZZZZZZZZ
[23424.121394] Padding 00000000d0fbb94c: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a  ZZZZZZZZZZZZZZZZ
[23424.121397] Padding 00000000bcb27a87: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a  ZZZZZZZZZZZZZZZZ
[23424.121743] CPU: 7 PID: 12174 Comm: vgs Tainted: G    B   W    L
5.0.0-rc7-next-20190221+ #7
[23424.121758] Call Trace:
[23424.121762] [c0000004ce5bf7b0] [c0000000007deb8c] dump_stack+0xb0/0xf4
(unreliable)
[23424.121770] [c0000004ce5bf7f0] [c00000000037d310] print_trailer+0x250/0x278
[23424.121775] [c0000004ce5bf880] [c00000000036d578]
check_bytes_and_report+0x138/0x160
[23424.121779] [c0000004ce5bf920] [c00000000036fac8] check_object+0x348/0x3e0
[23424.121784] [c0000004ce5bf990] [c00000000036fd18]
alloc_debug_processing+0x1b8/0x2c0
[23424.121788] [c0000004ce5bfa30] [c000000000372d14] ___slab_alloc+0xbb4/0xfa0
[23424.121792] [c0000004ce5bfb60] [c000000000373134] __slab_alloc+0x34/0x60
[23424.121802] [c0000004ce5bfb90] [c000000000373664] kmem_cache_alloc+0x504/0x5c0
[23424.121812] [c0000004ce5bfc20] [c000000000476a9c] io_submit_one+0x9c/0xb20
[23424.121824] [c0000004ce5bfd50] [c000000000477f10] sys_io_submit+0xe0/0x350
[23424.121832] [c0000004ce5bfe20] [c00000000000b000] system_call+0x5c/0x70
[23424.121836] FIX aio_kiocb: Restoring 0x000000009f1f5145-0x00000000841e301b=0x6b
[23424.121836]
[23424.121840] FIX aio_kiocb: Marking all objects used

