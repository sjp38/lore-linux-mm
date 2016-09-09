Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB396B0069
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 22:10:19 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id o7so70380950oif.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 19:10:19 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id h187si383863oic.32.2016.09.08.19.10.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 19:10:18 -0700 (PDT)
Subject: Re: [PATCH v8 00/16] fix some type infos and bugs for arm64/of numa
References: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
 <20160908110119.GG1493@arm.com>
From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Message-ID: <57D2197E.1030402@huawei.com>
Date: Fri, 9 Sep 2016 10:07:58 +0800
MIME-Version: 1.0
In-Reply-To: <20160908110119.GG1493@arm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank
 Rowand <frowand.list@gmail.com>, devicetree <devicetree@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>



On 2016/9/8 19:01, Will Deacon wrote:
> On Thu, Sep 01, 2016 at 02:54:51PM +0800, Zhen Lei wrote:
>> v7 -> v8:
>> Updated patches according to Will Deacon's review comments, thanks.
>>
>> The changed patches is: 3, 5, 8, 9, 10, 11, 12, 13, 15
>> Patch 3 requires an ack from Rob Herring.
>> Patch 10 requires an ack from linux-mm.
>>
>> Hi, Will:
>> Something should still be clarified:
>> Patch 5, I modified it according to my last reply. BTW, The last sentence
>>          "srat_disabled() ? -EINVAL : 0" of arm64_acpi_numa_init should be moved
>>          into acpi_numa_init, I think.
>>          
>> Patch 9, I still leave the code in arch/arm64.
>>          1) the implementation of setup_per_cpu_areas on all platforms are different.
>>          2) Although my implementation referred to PowerPC, but still something different.
>>
>> Patch 15, I modified the description again. Can you take a look at it? If this patch is
>> 	  dropped, the patch 14 should also be dropped.
>>
>> Patch 16, How many times the function node_distance to be called rely on the APP(need many tasks
>>           to be scheduled), I have not prepared yet, so I give up this patch as your advise. 
> 
> Ok, I'm trying to pick the pieces out of this patch series and it's not
> especially easy. As far as I can tell:
> 
>   Patch 3 needs an ack from the device-tree folks
Rob just acked.

> 
>   Patch 10 needs an ack from the memblock folks
I'll immediately send a email to remind them.

> 
>   Patch 11 depends on patch 10
> 
>   Patches 14,15,16 can wait for the time being (I still don't see their
>   value).
OK, that's no problem. So I put them in the end beforehand.

> 
> So, I could pick up patches 1-2, 4-9 and 12-13 but it's not clear whether
Now you can also add patch 3.

> that makes any sense. The whole series seems to be a mix of trivial printk
The most valueable patches are: patch 2, 9, 11. The other is just because of a programmer wants the code to be nice.

> cleanups, a bunch of core OF stuff, some new features and then some
> questionable changes at the end.
> 
> Please throw me a clue,
> 
> Will
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
