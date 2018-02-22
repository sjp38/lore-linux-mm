Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 042886B02DE
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 09:14:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k2so1022833wmf.9
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 06:14:11 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id d7si319938edl.385.2018.02.22.06.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 06:14:10 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [Question PATCH 0/1] mm: crash in vmalloc_to_page - misuse or bug?
Date: Thu, 22 Feb 2018 16:13:23 +0200
Message-ID: <20180222141324.5696-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: willy@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Igor Stoppa <igor.stoppa@huawei.com>

While trying to change the code of find_vm_area, I got an automated
notification that my code was breaking the testing of i386, based on the
0-day testing automation from 01.org

I started investigating the issue and noticed that it seems to be
reproducible also on top of plain 4.16-rc2, without any of my patches.

I'm still not 100% sure that I'm doing something sane, but I thought it
might be good to share the finding.

The patch contains both a minimal change, to trigger the crash, and a
snippet of the log of the crash i get.

Igor Stoppa (1):
  crash vmalloc_to_page()

 mm/vmalloc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
