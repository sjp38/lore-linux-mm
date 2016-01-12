Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A0204680F80
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 20:07:08 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id yy13so237319063pab.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 17:07:08 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id y73si2865598pfi.218.2016.01.11.17.07.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 17:07:07 -0800 (PST)
Message-ID: <56945142.5040509@huawei.com>
Date: Tue, 12 Jan 2016 09:05:06 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add ratio in slabinfo print
References: <56932791.3080502@huawei.com> <20160111122553.GB27317@dhcp22.suse.cz> <5693AAD5.6090101@huawei.com> <alpine.DEB.2.10.1601111619120.5824@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1601111619120.5824@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, cl@linux.com, Pekka Enberg <penberg@kernel.org>, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, zhong jiang <zhongjiang@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/1/12 8:20, David Rientjes wrote:

> On Mon, 11 Jan 2016, Xishi Qiu wrote:
> 
>>> On Mon 11-01-16 11:54:57, Xishi Qiu wrote:
>>>> Add ratio(active_objs/num_objs) in /proc/slabinfo, it is used to show
>>>> the availability factor in each slab.
>>>
>>> What is the reason to add such a new value when it can be trivially
>>> calculated from the userspace?
>>>
>>> Besides that such a change would break existing parsers no?
>>
>> Oh, maybe it is.
>>
> 
> If you need the information internally, you could always create a library 
> around slabinfo and export the information for users who are interested 
> for your own use.  Doing anything other than appending fields to each line 
> is too dangerous, however, as a general rule.
> 
> 

OK, I know.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
