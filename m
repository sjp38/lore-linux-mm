Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id A22A96B02C3
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 22:52:07 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id f20so90058430otd.9
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:52:07 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 31si4821002otq.174.2017.06.19.19.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 19:52:06 -0700 (PDT)
Subject: Re: [PATCH] mm/list_lru.c: use cond_resched_lock() for nlru->lock
References: <1497228440-10349-1-git-send-email-stummala@codeaurora.org>
 <20170615140523.76f8fc3ca21dae3704f06a56@linux-foundation.org>
 <20170617111431.GA27061@esperanza>
From: Sahitya Tummala <stummala@codeaurora.org>
Message-ID: <6ab790fe-de97-9495-0d3b-804bae5d7fbb@codeaurora.org>
Date: Tue, 20 Jun 2017 08:22:01 +0530
MIME-Version: 1.0
In-Reply-To: <20170617111431.GA27061@esperanza>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hello,

On 6/17/2017 4:44 PM, Vladimir Davydov wrote:

>
> That said, I think it would be better to patch shrink_dcache_sb() or
> dentry_lru_isolate_shrink() instead of list_lru_walk() in order to fix
> this lockup.

Thanks for the review. I will enhance the patch as per your suggestion.

-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
