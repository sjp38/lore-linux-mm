Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f48.google.com (mail-lf0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC786B0005
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 10:07:50 -0400 (EDT)
Received: by mail-lf0-f48.google.com with SMTP id j11so11238897lfb.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 07:07:50 -0700 (PDT)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id j3si19363660lbc.107.2016.04.05.07.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 07:07:49 -0700 (PDT)
Received: by mail-lb0-x229.google.com with SMTP id vo2so10098897lbb.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 07:07:48 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 5 Apr 2016 15:07:48 +0100
Message-ID: <CALjTZvavWqtLoGQiWb+HxHP4rwRwaZiP0QrPRb+9kYGdicXohg@mail.gmail.com>
Subject: [BUG] lib: zram lz4 compression/decompression still broken on big endian
From: Rui Salvaterra <rsalvaterra@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: eunb.song@samsung.com, gregkh@linuxfoundation.org, minchan@kernel.org, linux-mm@kvack.org

Hi,


I apologise in advance if I've cc'ed too many/the wrong people/lists.

Whenever I try to use zram with lz4, on my Power Mac G5 (tested with
kernel 4.4.0-16-powerpc64-smp from Ubuntu 16.04 LTS), I get the
following on my dmesg:

[13150.675820] zram: Added device: zram0
[13150.704133] zram0: detected capacity change from 0 to 5131976704
[13150.715960] zram: Decompression failed! err=-1, page=0
[13150.716008] zram: Decompression failed! err=-1, page=0
[13150.716027] zram: Decompression failed! err=-1, page=0
[13150.716032] Buffer I/O error on dev zram0, logical block 0, async page read

I believe Eunbong Song wrote a patch [1] to fix this (or a very
identical) bug on MIPS, but it never got merged (maybe
incorrect/incomplete?). Is there any hope of seeing this bug fixed?


Thanks,

Rui Salvaterra


[1] http://comments.gmane.org/gmane.linux.kernel/1752745

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
