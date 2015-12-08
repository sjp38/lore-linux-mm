Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C4AC76B027C
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 19:25:34 -0500 (EST)
Received: by wmec201 with SMTP id c201so9171646wme.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 16:25:34 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id f81si27006970wmh.9.2015.12.07.16.25.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 16:25:33 -0800 (PST)
Received: by wmec201 with SMTP id c201so190192306wme.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 16:25:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1448636635-15946-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1448636635-15946-1-git-send-email-izumi.taku@jp.fujitsu.com>
Date: Mon, 7 Dec 2015 16:25:32 -0800
Message-ID: <CA+8MBb++DH+X-KHaABBTzOc0ygkiR0xU4JpJaLmXac90kFf6pw@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] mm: Introduce kernelcore=reliable option
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, matt@codeblueprint.co.uk

Sorry for the slow turnaround testing this.

This version seems to do better with my quirky system.
Summary of /proc/zoneinfo now looks like this:

$ ./zoneinfo
Node          Normal         Movable             DMA           DMA32
   0        17090.04        85687.43           14.93         1677.41
   1        17949.70        81490.98
   2        17911.66        85675.00
   3        17936.42        85313.32

which gets close to the mirror numbers reported in early part of boot:

[    0.000000] efi: Memory: 81050M/420096M mirrored memory

SUM(Normal) = 70887.82

There are ~8GB of "struct page" allocated from boot time allocator,
which covers most of the difference in the values.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
