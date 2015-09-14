Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 70DFA6B0257
	for <linux-mm@kvack.org>; Sat,  5 Dec 2015 14:55:35 -0500 (EST)
Received: by qgea14 with SMTP id a14so115648232qge.0
        for <linux-mm@kvack.org>; Sat, 05 Dec 2015 11:55:35 -0800 (PST)
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com. [129.33.205.208])
        by mx.google.com with ESMTPS id m90si3920523qkh.121.2015.12.05.11.55.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 05 Dec 2015 11:55:34 -0800 (PST)
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Sat, 5 Dec 2015 14:55:34 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 989E66E8045
	for <linux-mm@kvack.org>; Sat,  5 Dec 2015 14:43:41 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tB5JtV6723920742
	for <linux-mm@kvack.org>; Sat, 5 Dec 2015 19:55:32 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tB5JtVPW007488
	for <linux-mm@kvack.org>; Sat, 5 Dec 2015 14:55:31 -0500
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] hanging swapoff with HAVE_ARCH_SOFT_DIRTY=y
Date: Mon, 14 Sep 2015 11:24:46 +0200
Message-Id: <1442222687-9758-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

Greetings,

while implementing software dirty bits for s390 we noticed that the swapoff
command at shutdown caused the system to hang. After some debugging I found
the maybe_same_pte() function to be the cause of this.

The bug shows up for any configuration with CONFIG_HAVE_ARCH_SOFT_DIRTY=y
and CONFIG_MEM_SOFT_DIRTY=n. Currently this affects x86_64 only.

Martin Schwidefsky (1):
  mm/swapfile: fix swapoff with software dirty bits enabled

 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
