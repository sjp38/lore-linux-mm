Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCE76B0038
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 20:54:17 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id tp5so9771222ieb.26
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 17:54:17 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id c88si10734301iod.26.2014.11.24.17.54.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Nov 2014 17:54:16 -0800 (PST)
Message-ID: <5473E146.7000503@codeaurora.org>
Date: Mon, 24 Nov 2014 17:54:14 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] Improving CMA
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Cc: zhuhui@xiaomi.com, minchan@kernel.org, iamjoonsoo.kim@lge.com, gioh.kim@lge.com, SeongJae Park <sj38.park@gmail.com>

There have been a number of patch series posted designed to improve various
aspects of CMA. A sampling:

https://lkml.org/lkml/2014/10/15/623
http://marc.info/?l=linux-mm&m=141571797202006&w=2
https://lkml.org/lkml/2014/6/26/549

As far as I can tell, these are all trying to fix real problems with CMA but
none of them have moved forward very much from what I can tell. The goal of
this session would be to come out with an agreement on what are the biggest
problems with CMA and the best ways to solve them.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
