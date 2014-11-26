Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A18496B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 00:55:30 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so2157583pac.39
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 21:55:30 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id xj9si5236927pab.73.2014.11.25.21.55.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 21:55:29 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id w10so2110516pde.19
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 21:55:28 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Date: Wed, 26 Nov 2014 14:56:37 +0900 (KST)
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Improving CMA
In-Reply-To: <54755621.6050700@lge.com>
Message-ID: <alpine.DEB.2.10.1411261438040.6720@hxeon>
References: <5473E146.7000503@codeaurora.org> <20141125113225.GH2725@suse.de> <54755621.6050700@lge.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="781441777-2032870768-1416981410=:6720"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>, minchan@kernel.org, zhuhui@xiaomi.com, iamjoonsoo.kim@lge.com

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--781441777-2032870768-1416981410=:6720
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT

Hi Gioh,

On Wed, 26 Nov 2014, Gioh Kim wrote:

>
>
> 2014-11-25 i??i?? 8:32i?? Mel Gorman i?'(e??) i?' e,?:
>> On Mon, Nov 24, 2014 at 05:54:14PM -0800, Laura Abbott wrote:
>>> There have been a number of patch series posted designed to improve 
>>> various
>>> aspects of CMA. A sampling:
>>> 
>>> https://lkml.org/lkml/2014/10/15/623
>>> http://marc.info/?l=linux-mm&m=141571797202006&w=2
>>> https://lkml.org/lkml/2014/6/26/549
>>> 
>>> As far as I can tell, these are all trying to fix real problems with CMA 
>>> but
>>> none of them have moved forward very much from what I can tell. The goal 
>>> of
>>> this session would be to come out with an agreement on what are the 
>>> biggest
>>> problems with CMA and the best ways to solve them.
>>> 
>> 
>> I think this is a good topic. Some of the issues have been brought up 
>> before
>> at LSF/MM but they never made that much traction so it's worth revisiting. 
>> I
>> haven't been paying close attention to the mailing list discussions but
>> I've been a little worried that the page allocator paths are turning into
>> a bigger and bigger mess. I'm also a bit worried that options such as
>> migrating pages out of CMA areas that are about to be pinned for having
>> callback options to forcibly free pages never went anywhere.
>> 
>
>
> I have two question.
>
> First, is GCMA able to replace CMA? It's news to me.

Yes, it can. GCMA could replace or co-exist and be used selectively with 
CMA. You could replace CMA with GCMA by simply changing 
cma_declare_contiguous() function call with gcma_declare_contiguous().

> I need some time to check GCMA.

1st RFC of GCMA was posted on linux-mm mailing list as Laura linked and 
you could get whole code from gcma/rfc/v1 tag of 
https://github.com/sjp38/linux.gcma. It would great for me if you could 
check it and give me any feedback because GCMA have lots of TODO / Future 
plans and 2nd RFC is acively developing already.

Thanks,
SeongJae Park

>
> Second, is CMA popular enough to change allocator path?
> Yes, I need it.
> But I don't know any company uses it, and nobody seems to have interest in 
> it.
>
--781441777-2032870768-1416981410=:6720--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
