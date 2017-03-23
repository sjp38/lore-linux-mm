Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1174D6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 06:07:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so427184351pgc.6
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 03:07:20 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id g1si5026140pln.322.2017.03.23.03.07.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Mar 2017 03:07:19 -0700 (PDT)
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0ON9008CWIS32990@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 23 Mar 2017 10:07:15 +0000 (GMT)
Subject: Re: [PATCH v2] userfaultfd: provide pid in userfault msg
From: Alexey Perevalov <a.perevalov@samsung.com>
Message-id: <9c1b88f6-b862-efd5-725f-a5fd083599dc@samsung.com>
Date: Thu, 23 Mar 2017 13:07:12 +0300
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
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Andrea Arcangeli' <aarcange@redhat.com>, "'Dr . David Alan Gilbert'" <dgilbert@redhat.com>, linux-mm@kvack.org, i.maximets@samsung.com

On 03/23/2017 12:42 PM, Hillf Danton wrote:
> On March 23, 2017 2:29 AM Alexey Perevalov wrote:
>>   static inline struct uffd_msg userfault_msg(unsigned long address,
>>   					    unsigned int flags,
>> -					    unsigned long reason)
>> +					    unsigned long reason,
>> +					    unsigned int features)
> Nit: the type of feature is u64 by define.
>
Yes, you right, it's different types, especially for 32bit architectures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
