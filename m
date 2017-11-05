Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6976B0033
	for <linux-mm@kvack.org>; Sun,  5 Nov 2017 16:56:50 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id p96so4927224wrb.12
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 13:56:50 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id c10si9624957wrg.554.2017.11.05.13.56.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Nov 2017 13:56:45 -0800 (PST)
Date: Sun, 5 Nov 2017 22:56:32 +0100 (CET)
From: Stefan Wahren <stefan.wahren@i2se.com>
Message-ID: <1976258473.140703.1509918992800@email.1und1.de>
Subject: Re: [1/2] mm: drop migrate type checks from has_unmovable_pages
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>

Hi Michal,

the dwc2 USB driver on BCM2835 in linux-next is affected by the CMA allocation issue. A quick web search guide me to your patch, which avoid the issue.

Since the patch wasn't accepted, i want to know is there another solution?
Is this an issue in dwc2?

Best regards
Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
