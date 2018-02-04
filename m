Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D577B6B0007
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 17:58:05 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m3so18357470pgd.20
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 14:58:05 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y15si1049608pgq.554.2018.02.04.14.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Feb 2018 14:58:04 -0800 (PST)
From: Alexey Skidanov <alexey.skidanov@intel.com>
Subject: Possible reasons of CMA allocation failure
Message-ID: <10f52913-ad8b-4fd2-5e55-47aa46c48c0d@intel.com>
Date: Mon, 5 Feb 2018 00:58:28 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, labbott@redhat.com

Hello,

On x86 machine with 16GB RAM installed, I reserved 1 GB area for CMA:
[    0.000000] cma: Reserved 1024 MiB at 0x00000003fcc00000

Some time after the boot, CMa failed to allocate chunk of memory while
there are enough contiguous pages:

[  392.132392] cma: cma_alloc: alloc failed, req-size: 200000 pages,
ret: -16
[  392.132393] cma: number of available pages:
6@8314+9@8343+9@8375+253648@8496=> 253672 free of 262144 total pages
[  392.132398] cma: cma_alloc(): returned (null)

What are the possible reasons for such failure (besides the pinned user
allocated pages) ?

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
