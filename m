Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 89F216B0038
	for <linux-mm@kvack.org>; Sat, 25 Mar 2017 07:47:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n5so6902352pgd.19
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 04:47:45 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id n73si4349948pfb.276.2017.03.25.04.47.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 25 Mar 2017 04:47:44 -0700 (PDT)
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OND00L9GCRHCI50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Sat, 25 Mar 2017 11:47:41 +0000 (GMT)
Subject: Re: [PATCH v2] userfaultfd: provide pid in userfault msg
From: Alexey Perevalov <a.perevalov@samsung.com>
Message-id: <105a751b-254a-d2e3-441e-1418a8e30905@samsung.com>
Date: Sat, 25 Mar 2017 14:47:37 +0300
MIME-version: 1.0
In-reply-to: <00af01d2a3b9$c23b5030$46b1f090$@alibaba-inc.com>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
References: <1490207346-9703-1-git-send-email-a.perevalov@samsung.com>
 <CGME20170322182918eucas1p204ef2f7aadb0ac41d11f15ef434c74c4@eucas1p2.samsung.com>
 <1490207346-9703-2-git-send-email-a.perevalov@samsung.com>
 <00af01d2a3b9$c23b5030$46b1f090$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrea Arcangeli' <aarcange@redhat.com>
Cc: "'Dr . David Alan Gilbert'" <dgilbert@redhat.com>, linux-mm@kvack.org, i.maximets@samsung.com


Hi, Hillf

On 03/23/2017 12:42 PM, Hillf Danton wrote:
> On March 23, 2017 2:29 AM Alexey Perevalov wrote:
>>   static inline struct uffd_msg userfault_msg(unsigned long address,
>>   					    unsigned int flags,
>> -					    unsigned long reason)
>> +					    unsigned long reason,
>> +					    unsigned int features)
> Nit: the type of feature is u64 by define.
>
>
>
>
>

Yes, let me clarify once again,
type of features is u64, but in struct uffdio_api, which used for handling
UFFDIO_API.
Function userfault_msg is using in handle_userfault, when only
context (struct userfaultfd_ctx) is available, features inside context is
type of unsigned int and uffd_ctx_features is using for casting.
It's more likely question to maintainer, but due to userfaultfd_ctx is 
internal only
structure, it's not a big problem to extend it in the future.


-- 
Best regards,
Alexey Perevalov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
