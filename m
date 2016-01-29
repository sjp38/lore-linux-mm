Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id DBFE66B0255
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 07:51:55 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id r129so67201123wmr.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 04:51:55 -0800 (PST)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id d3si21990946wja.39.2016.01.29.04.51.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 04:51:55 -0800 (PST)
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Fri, 29 Jan 2016 12:51:54 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 55B281B08061
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 12:52:01 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0TCpqK010617170
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 12:51:52 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0TCpoNe001021
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:51:52 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 0/1] additional CONFIG_DEBUG_PAGEALLOC change
Date: Fri, 29 Jan 2016 13:52:13 +0100
Message-Id: <1454071934-24291-3-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1454071934-24291-1-git-send-email-borntraeger@de.ibm.com>
References: <1454071934-24291-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Christian Borntraeger <borntraeger@de.ibm.com>

As suggested by David Rientjes, we should also change free_init_pages.

Can be merged with "x86: query dynamic DEBUG_PAGEALLOC setting"
or go as addon patch.


Christian Borntraeger (1):
  x86: also use debug_pagealloc_enabled() for free_init_pages

 arch/x86/mm/init.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
