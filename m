Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 529926B006C
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:24:32 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so228824607pad.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:24:32 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id f12si6002060pat.144.2015.03.24.08.24.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 08:24:31 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so228832288pac.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:24:31 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 0/2] zs_object_copy() micro-optimizations
Date: Wed, 25 Mar 2015 00:24:45 +0900
Message-Id: <1427210687-6634-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

two small patches two micro-optimize zs_object_copy().

The first one removes unneeded kunmap_atomic/kmap_atomic of dst page,
when object that we copy belongs to two source pages.

The seconds one is also trivial -- removes branching and (a bit)
reduses the amount of work done by the function (double offsets
calculations).

Sergey Senozhatsky (2):
  zsmalloc: do not remap dst page while prepare next src page
  zsmalloc: micro-optimize zs_object_copy()

 mm/zsmalloc.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
