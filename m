Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83AAC6B0292
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 23:12:38 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p77so1113130ioe.11
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 20:12:38 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id t68si481611ioe.23.2017.06.06.20.12.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 20:12:37 -0700 (PDT)
Message-ID: <59376DEA.2080900@huawei.com>
Date: Wed, 7 Jun 2017 11:07:22 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: do not pass reclaimed slab to vmpressure
References: <1485344318-6418-1-git-send-email-vinmenon@codeaurora.org> <20170125232713.GB20811@bbox> <CAOaiJ-mk=SmNR4oK+udhJNxHzmobf28wSu+nf449c=1cHMBDAg@mail.gmail.com> <20170126141836.GA3584@bbox> <CAOaiJ-m=X=8GpLCW-7wVkBmT=Gq9V9ocXtcXbmNNALffLepWeg@mail.gmail.com> <20170130234028.GA7942@bbox> <5936A787.4050002@huawei.com> <20170607025324.GB18007@bbox>
In-Reply-To: <20170607025324.GB18007@bbox>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: vinayak menon <vinayakm.list@gmail.com>, Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Shiraz Hashim <shiraz.hashim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 2017/6/7 10:53, Minchan Kim wrote:
> Hi,
>
> On Tue, Jun 06, 2017 at 09:00:55PM +0800, zhong jiang wrote:
>> On 2017/1/31 7:40, Minchan Kim wrote:
>>> Hi Vinayak,
>>> Sorry for late response. It was Lunar New Year holidays.
>>>
>>> On Fri, Jan 27, 2017 at 01:43:23PM +0530, vinayak menon wrote:
>>>>> Thanks for the explain. However, such case can happen with THP page
>>>>> as well as slab. In case of THP page, nr_scanned is 1 but nr_reclaimed
>>>>> could be 512 so I think vmpressure should have a logic to prevent undeflow
>>>>> regardless of slab shrinking.
>>>>>
>>>> I see. Going to send a vmpressure fix. But, wouldn't the THP case
>>>> result in incorrect
>>>> vmpressure reporting even if we fix the vmpressure underflow problem ?
>>> If a THP page is reclaimed, it reports lower pressure due to bigger
>>> reclaim ratio(ie, reclaimed/scanned) compared to normal pages but
>>> it's not a problem, is it? Because VM reclaimed more memory than
>>> expected so memory pressure isn't severe now.
>>   Hi, Minchan
>>
>>   THP lru page is reclaimed, reclaim ratio bigger make sense. but I read the code, I found
>>   THP is split to normal pages and loop again.  reclaimed pages should not be bigger
>>    than nr_scan.  because of each loop will increase nr_scan counter.
>>  
>>    It is likely  I miss something.  you can point out the point please.
> You are absolutely right.
>
> I got confused by nr_scanned from isolate_lru_pages and sc->nr_scanned
> from shrink_page_list.
>
> Thanks.
>
>
> .
>
 Hi, Minchan

 I will send the revert patch shortly. how do you think?

 Thanks
 zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
