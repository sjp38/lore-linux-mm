Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9EDF66B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 10:06:01 -0400 (EDT)
Received: by iggg4 with SMTP id g4so67264308igg.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 07:06:01 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id ke17si2599532icb.92.2015.04.09.07.06.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 07:06:01 -0700 (PDT)
Message-ID: <55268741.8010301@codeaurora.org>
Date: Thu, 09 Apr 2015 19:35:53 +0530
From: Susheel Khiani <skhiani@codeaurora.org>
MIME-Version: 1.0
Subject: [Question] ksm: rmap_item pointing to some stale vmas
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, peterz@infradead.org, neilb@suse.de, dhowells@redhat.com, hughd@google.com, paulmcquad@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

We are seeing an issue during try_to_unmap_ksm where in call to 
try_to_unmap_one is failing.

try_to_unmap_ksm in this particular case is trying to go through vmas 
associated with each rmap_item->anon_vma. What we see is this that the 
corresponding page is not mapped to any of the vmas associated with 2 
rmap_item.

The associated rmap_item in this case looks like pointing to some valid 
vma but the said page is not found to be mapped under it. 
try_to_unmap_one thus fails to find valid ptes for these vmas.

At the same time we can see that the page actually is mapped in 2 
separate and different vmas which are not part of rmap_item associated 
with page.

So whether rmap_item is pointing to some stale vmas and now the mapping 
has changed? Or there is something else going on here.
p
Any pointer would be appreciated.

-- 
Susheel Khiani

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
