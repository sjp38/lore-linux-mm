Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5FA6B04CB
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 03:06:50 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b127so27866183lfb.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:06:50 -0700 (PDT)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id f203si5962140lfe.113.2017.07.11.00.06.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 00:06:48 -0700 (PDT)
Received: by mail-lf0-x232.google.com with SMTP id t72so76812416lff.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:06:48 -0700 (PDT)
MIME-Version: 1.0
From: Zhizhou Tian <zhizhou.tian@gmail.com>
Date: Tue, 11 Jul 2017 15:06:47 +0800
Message-ID: <CAJMwaskTNg-QqouLOjHBrkbu7QMH=UdP1diVH38Xp5qWbpho1w@mail.gmail.com>
Subject: "zram: user per-cpu compression streams" do not have good proformance
 on my hardware?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

hi,
   I am porting this patch "zram: user per-cpu compression streams"
(https://patchwork.kernel.org/patch/8971921/) back to my arm64cpu/1G
memory hardware.
   On original version, all cpus use one zram compress stream while swapping
out. After patch every cpu has a compress stream. I did get a nice look
result with fio test, but with a monkey-like test, it is not as good.
   Maybe L2 cpu cache caused this issue? How can i find out what
caused this issue? Welcome and thank your suggestions ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
