Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 875336B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 12:50:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z9-v6so1309019pfe.23
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 09:50:43 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id z1-v6si1429920plb.152.2018.07.03.09.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 09:50:41 -0700 (PDT)
Subject: Re: [RFC v3 PATCH 5/5] x86: check VM_DEAD flag in page fault
References: <1530311985-31251-6-git-send-email-yang.shi@linux.alibaba.com>
 <84eba553-2e0b-1a90-d543-6b22c1b3c5f8@linux.vnet.ibm.com>
 <20180702121528.GM19043@dhcp22.suse.cz>
 <80406cbd-67f4-ca4c-cd54-aeb305579a72@linux.vnet.ibm.com>
 <20180702124558.GP19043@dhcp22.suse.cz>
 <e6f8d0e2-48c1-f610-c00b-d05d4bd0d9eb@linux.vnet.ibm.com>
 <20180702133733.GU19043@dhcp22.suse.cz>
 <6fd4eb3d-ef66-7a37-4adb-05c22ac51d95@linux.alibaba.com>
 <20180702175749.GG19043@dhcp22.suse.cz>
 <a5b4888c-6518-df47-bc0d-d4173984daa9@linux.alibaba.com>
 <20180703061713.GB16767@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <472ce7f9-be53-c741-6bad-f46ec9dfbb8a@linux.alibaba.com>
Date: Tue, 3 Jul 2018 09:50:19 -0700
MIME-Version: 1.0
In-Reply-To: <20180703061713.GB16767@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, willy@infradead.org, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org



On 7/2/18 11:17 PM, Michal Hocko wrote:
> On Mon 02-07-18 11:10:23, Yang Shi wrote:
>> On 7/2/18 10:57 AM, Michal Hocko wrote:
> [...]
>>> Why would you even care about shared mappings?
>> Just thought about we are dealing with VM_DEAD, which means the vma will be
>> tore down soon regardless it is shared or non-shared.
>>
>> MMF_UNSTABLE doesn't care about !shared case.

Sorry, this is a typo, it should be "shared".

> Let me clarify some more. MMF_UNSTABLE is there to prevent from
> unexpected page faults when the mm is torn down by the oom reaper. And
> oom reaper only cares about private mappings because we do not touch
> shared ones. Disk based shared mappings should be a non-issue for
> VM_DEAD because even if you race and refault a page back then you know
> it is the same one you have seen before. Memory backed shared mappings
> are a different story because you can get a fresh new page. oom_reaper
> doesn't care because it doesn't tear those down. You would have to but
> my primary point was that we already have MMF_UNSTABLE so all you need
> is to extend it to memory backed shared mappings (shmem and hugetlb).

Yes, sure. I think I got your point. Thanks for the elaboration.

Yang

>
