Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 227B06B0070
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 00:53:02 -0400 (EDT)
Received: from eusync2.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MBM0085F08ZRS90@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 09 Oct 2012 05:53:23 +0100 (BST)
Received: from [172.16.228.128] ([10.90.7.109])
 by eusync2.samsung.com (Oracle Communications Messaging Server 7u4-23.01
 (7.0.4.23.0) 64bit (built Aug 10 2011))
 with ESMTPA id <0MBM00309089V030@eusync2.samsung.com> for linux-mm@kvack.org;
 Tue, 09 Oct 2012 05:53:00 +0100 (BST)
Message-id: <5073ADC9.7030201@samsung.com>
Date: Tue, 09 Oct 2012 06:53:29 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: CMA and zone watermarks
References: 
 <CAH+eYFCJTtF+FeqKs_ho5yyX0tkUBoaa-yfsd1rVshcQ5Xxp=A@mail.gmail.com>
 <20121009031023.GF13817@bbox> <50739615.9080205@samsung.com>
 <20121009044317.GG13817@bbox>
In-reply-to: <20121009044317.GG13817@bbox>
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Rabin Vincent <rabin@rab.in>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello,

On 10/9/2012 6:43 AM, Minchan Kim wrote:
> On Tue, Oct 09, 2012 at 05:12:21AM +0200, Marek Szyprowski wrote:
>> On 10/9/2012 5:10 AM, Minchan Kim wrote:
>>> On Mon, Oct 08, 2012 at 05:41:14PM +0200, Rabin Vincent wrote:

>>> Fortunately, recently, Bart sent a patch about that.
>>> http://marc.info/?l=linux-mm&m=134763299016693&w=2
>>>
>>> Could you test above patches in your kernel?
>>> You have to apply [2/4], [3/4], [4/4] and don't need [1/4].
>>
>> AFAIR without patch [1/4], free cma page counter will go below zero
>> and weird thing will happen, so better apply the complete patchset.
>
> I can't understand your point. [1/4] is just fix for correcting trace
> No?

I just remember we ran into such strange negative number of free cma 
pages issue without that patch, but maybe the final patchset will simply 
fail to apply without the first patch.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
