Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1736B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:29:57 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j194so942920oib.15
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 15:29:57 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id v72si5224735oia.253.2017.07.19.15.29.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 15:29:56 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Wed, 19 Jul 2017 15:29:55 -0700
From: Sodagudi Prasad <psodagud@codeaurora.org>
Subject: Re: [PATCH] llist: clang: introduce member_address_is_nonnull()
Reply-To: 20170719182730.65794-1-glider@google.com
Message-ID: <23929a394b325995511c106636862a89@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glider@google.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, md@google.com, ndesaulniers@google.com, ghackmann@google.com, mka@google.com, dvyukov@google.com, kcc@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, mingo@elte.hu


Hi All,

Observed boot up crash with clang in kerne/sched/core.c file 
sched_ttwu_pending() function, because it is using 
llist_for_each_entry_safe().
After pulling patch from a??https://lkml.org/lkml/2017/7/19/1169, no crash 
observed.

Tested-by: Sodagudi Prasad <psodagud@codeaurora.org>

-Thanks, Prasad
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora 
Forum,
Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
