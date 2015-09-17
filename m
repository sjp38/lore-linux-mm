Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id B69E46B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 04:59:38 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so14263408wic.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 01:59:38 -0700 (PDT)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id gy7si2701933wib.14.2015.09.17.01.59.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Sep 2015 01:59:37 -0700 (PDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 17 Sep 2015 09:59:09 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id BB8882190046
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 09:58:33 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8H8x2hL36831236
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 08:59:02 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8H8x1js027289
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:59:02 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] hanging swapoff with HAVE_ARCH_SOFT_DIRTY=y
Date: Thu, 17 Sep 2015 10:58:58 +0200
Message-Id: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

Greetings,

while implementing software dirty bits for s390 we noticed that the swapoff
command at shutdown caused the system to hang. After some debugging I found
the maybe_same_pte() function to be the cause of this.

The bug shows up for any configuration with CONFIG_HAVE_ARCH_SOFT_DIRTY=y
and CONFIG_MEM_SOFT_DIRTY=n. Currently this affects x86_64 only.

Martin Schwidefsky (1):
  mm/swapfile: fix swapoff vs. software dirty bits

 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
