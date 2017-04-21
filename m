Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83AD72806D2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 14:26:47 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o89so9661587wrc.1
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 11:26:47 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id l1si3342144wml.147.2017.04.21.11.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 11:26:46 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id o81so21850543wmb.1
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 11:26:46 -0700 (PDT)
MIME-Version: 1.0
From: Luigi Semenzato <semenzato@google.com>
Date: Fri, 21 Apr 2017 11:26:45 -0700
Message-ID: <CAA25o9SP_Axuhvrr-YNYdfj=NHjX1KaDrE-EOmw1gHYS2PpZCw@mail.gmail.com>
Subject: swapping file pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>, Johannes Weiner <hannes@cmpxchg.org>, vinmenon@codeaurora.org

On an SSD used by a typical chromebook (i.e. the one on my desk right
now), it takes about 300us to read a random 4k page, but it takes less
than 10us to lzo-decompress a page from the zram device.

Code compresses reasonably well (down to almost 50% for x86_64,
although only 66% for ARM32), so I may be better off swapping file
pages to zram, rather than reading them back from the SSD.  Before I
even get started trying to do this, can anybody tell me if this is a
stupid idea?  Or possibly a good idea, but totally impractical from an
implementation perspective?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
