Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC946B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 00:18:34 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id f3-v6so3910382plf.18
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 21:18:34 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id v8si212551pgs.356.2018.03.08.21.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 21:18:31 -0800 (PST)
Subject: Re: [PATCH v2] slub: use jitter-free reference while printing age
References: <1520492010-19389-1-git-send-email-cpandya@codeaurora.org>
 <alpine.DEB.2.20.1803081211230.14668@nuc-kabylake>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <2e02a8f9-8a28-1db4-3dde-8490ee294e5f@codeaurora.org>
Date: Fri, 9 Mar 2018 10:48:24 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803081211230.14668@nuc-kabylake>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/8/2018 11:42 PM, Christopher Lameter wrote:
> On Thu, 8 Mar 2018, Chintan Pandya wrote:
> 
>> In this case, object got freed later but 'age'
>> shows otherwise. This could be because, while
>> printing this info, we print allocation traces
>> first and free traces thereafter. In between,
>> if we get schedule out or jiffies increment,
>> (jiffies - t->when) could become meaningless.
> 
> Could you show the new output style too?

New output will exactly be same. 'age' is still
staying with single jiffies ref in both prints.

> 
> Acked-by: Christoph Lameter <cl@linux.com>
Thanks


Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
