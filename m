Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6736B0269
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 17:53:14 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id k9-v6so159146pff.5
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 14:53:14 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id ay1-v6si1677155plb.266.2018.07.23.14.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 14:53:13 -0700 (PDT)
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180720210626.5bnyddmn4avp2l3x@kshutemo-mobl1>
 <3118b646-681e-a2aa-dc7b-71d4821fa50f@linux.alibaba.com>
 <alpine.DEB.2.21.1807231329080.105582@chino.kir.corp.google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <91caed46-6437-a137-0dbc-dadd113f8d58@linux.alibaba.com>
Date: Mon, 23 Jul 2018 14:52:43 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1807231329080.105582@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, hughd@google.com, aaron.lu@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 7/23/18 1:31 PM, David Rientjes wrote:
> On Fri, 20 Jul 2018, Yang Shi wrote:
>
>> I agree to keep it for a while to let that security bug cool down, however, if
>> there is no user anymore, it sounds pointless to still keep a dead knob.
>>
> It's not a dead knob.  We use it, and for reasons other than
> CVE-2017-1000405.  To mitigate the cost of constantly compacting memory to
> allocate it after it has been freed due to memry pressure, we can either
> continue to disable it, allow it to be persistently available, or use a
> new value for use_zero_page to specify it should be persistently
> available.

My understanding is the cost of memory compaction is *not* unique for 
huge zero page, right? It is expected when memory pressure is met, even 
though huge zero page is disabled.
