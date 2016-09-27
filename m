Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43A07280266
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 02:07:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c84so9486635pfj.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 23:07:22 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id ra7si1079840pab.39.2016.09.26.23.07.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 23:07:21 -0700 (PDT)
Subject: Re: [PATCH 1/5] mm/vmalloc.c: correct a few logic error for
 __insert_vmap_area()
References: <57E20B54.5020408@zoho.com>
 <alpine.DEB.2.10.1609211408140.20971@chino.kir.corp.google.com>
 <034db3ec-e2dc-a6da-6dab-f0803900e19d@zoho.com>
 <alpine.DEB.2.10.1609211544510.41473@chino.kir.corp.google.com>
 <c5435f6f-d945-fae1-c17e-04530be08421@zoho.com>
 <alpine.DEB.2.10.1609211612280.42217@chino.kir.corp.google.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57EA0C86.3010303@zoho.com>
Date: Tue, 27 Sep 2016 14:07:02 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1609211612280.42217@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 09/22/2016 07:15 AM, David Rientjes wrote:
> On Thu, 22 Sep 2016, zijun_hu wrote:
> 
>>> We don't support inserting when va->va_start == tmp_va->va_end, plain and 
>>> simple.  There's no reason to do so.  NACK to the patch.
>>>
>> i am sorry i disagree with you because
>> 1) in almost all context of vmalloc, original logic treat the special case as normal
>>    for example, __find_vmap_area() or alloc_vmap_area()
> 
> The ranges are [start, end) like everywhere else.  __find_vmap_area() is 
> implemented as such for the passed address.  The address is aligned in 
> alloc_vmap_area(), there's no surprise here.  The logic is correct in 
> __insert_vmap_area().
> 
i am sorry to disagree with you
i will resend this patch with more detailed illustration


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
