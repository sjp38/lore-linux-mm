Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88CA66B0269
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 13:24:50 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id f10-v6so5928225pgv.22
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 10:24:50 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id l9-v6si8685116pgp.146.2018.07.02.10.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 10:24:49 -0700 (PDT)
Subject: Re: [RFC v3 PATCH 5/5] x86: check VM_DEAD flag in page fault
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-6-git-send-email-yang.shi@linux.alibaba.com>
 <84eba553-2e0b-1a90-d543-6b22c1b3c5f8@linux.vnet.ibm.com>
 <20180702121528.GM19043@dhcp22.suse.cz>
 <80406cbd-67f4-ca4c-cd54-aeb305579a72@linux.vnet.ibm.com>
 <20180702124558.GP19043@dhcp22.suse.cz>
 <e6f8d0e2-48c1-f610-c00b-d05d4bd0d9eb@linux.vnet.ibm.com>
 <20180702133733.GU19043@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6fd4eb3d-ef66-7a37-4adb-05c22ac51d95@linux.alibaba.com>
Date: Mon, 2 Jul 2018 10:24:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180702133733.GU19043@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: willy@infradead.org, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org



On 7/2/18 6:37 AM, Michal Hocko wrote:
> On Mon 02-07-18 15:33:11, Laurent Dufour wrote:
>>
>> On 02/07/2018 14:45, Michal Hocko wrote:
>>> On Mon 02-07-18 14:26:09, Laurent Dufour wrote:
>>>> On 02/07/2018 14:15, Michal Hocko wrote:
> [...]
>>>>> We already do have a model for that. Have a look at MMF_UNSTABLE.
>>>> MMF_UNSTABLE is a mm's flag, here this is a VMA's flag which is checked.
>>> Yeah, and we have the VMA ready for all places where we do check the
>>> flag. check_stable_address_space can be made to get vma rather than mm.
>> Yeah, this would have been more efficient to check that flag at the beginning
>> of the page fault handler rather than the end, but this way it will be easier
>> to handle the speculative page fault too ;)
> The thing is that it doesn't really need to be called earlier. You are
> not risking data corruption on file backed mappings.

OK, I just think it could save a few cycles to check the flag earlier.

If nobody think it is necessary, we definitely could re-use 
check_stable_address_space(), just return VM_FAULT_SIGSEGV for VM_DEAD 
vma, and check for both shared and non-shared.

Thanks,
Yang

>
