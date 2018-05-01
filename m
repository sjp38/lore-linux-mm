Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB3C36B0005
	for <linux-mm@kvack.org>; Tue,  1 May 2018 01:24:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w7so6399547pfd.9
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 22:24:43 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id l3-v6si8746441pld.96.2018.04.30.22.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 22:24:42 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] mm: vmalloc: Pass proper vm_start into
 debugobjects
References: <1523961828-9485-1-git-send-email-cpandya@codeaurora.org>
 <1523961828-9485-3-git-send-email-cpandya@codeaurora.org>
 <20180430160436.45f92ec5b3c78c84e4425ec4@linux-foundation.org>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <6cfa516c-162a-c08a-80b9-3fed0c616b76@codeaurora.org>
Date: Tue, 1 May 2018 10:54:34 +0530
MIME-Version: 1.0
In-Reply-To: <20180430160436.45f92ec5b3c78c84e4425ec4@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, khandual@linux.vnet.ibm.com, mhocko@kernel.org



On 5/1/2018 4:34 AM, Andrew Morton wrote:
> should check for it and do a WARN_ONCE so it gets fixed.

Yes, that was an idea in discussion but I've been suggested that it
could be intentional. But since you are raising this, I will try to dig
once again and share a patch with WARN_ONCE if passing intermediate
'addr' is absolutely not right thing to do.

Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
