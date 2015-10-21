Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA486B0257
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 05:51:30 -0400 (EDT)
Received: by pasz6 with SMTP id z6so50522266pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 02:51:30 -0700 (PDT)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id uv8si12188485pbc.80.2015.10.21.02.51.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Oct 2015 02:51:29 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 21 Oct 2015 15:21:26 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 36F203940057
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 15:21:24 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9L9pN2Z7602604
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 15:21:23 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9L9pCUE010132
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 15:21:13 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 0/3] Slub code refine
Date: Wed, 21 Oct 2015 17:51:03 +0800
Message-Id: <1445421066-10641-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>

Here are three patches for slub code refine.

Some of them are acked/reviewed, resend by including Andrew for comments. No
code change.

Wei Yang (3):
  mm/slub: correct the comment in calculate_order()
  mm/slub: use get_order() instead of fls()
  mm/slub: calculate start order with reserved in consideration

 mm/slub.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
