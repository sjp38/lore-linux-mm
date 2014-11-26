Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E28486B0069
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 23:25:11 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id w10so1974847pde.38
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 20:25:11 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id w6si4838560pdp.190.2014.11.25.20.25.08
        for <linux-mm@kvack.org>;
        Tue, 25 Nov 2014 20:25:10 -0800 (PST)
Message-ID: <54755621.6050700@lge.com>
Date: Wed, 26 Nov 2014 13:25:05 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Improving CMA
References: <5473E146.7000503@codeaurora.org> <20141125113225.GH2725@suse.de>
In-Reply-To: <20141125113225.GH2725@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>, minchan@kernel.org, zhuhui@xiaomi.com, iamjoonsoo.kim@lge.com



2014-11-25 i??i?? 8:32i?? Mel Gorman i?'(e??) i?' e,?:
> On Mon, Nov 24, 2014 at 05:54:14PM -0800, Laura Abbott wrote:
>> There have been a number of patch series posted designed to improve various
>> aspects of CMA. A sampling:
>>
>> https://lkml.org/lkml/2014/10/15/623
>> http://marc.info/?l=linux-mm&m=141571797202006&w=2
>> https://lkml.org/lkml/2014/6/26/549
>>
>> As far as I can tell, these are all trying to fix real problems with CMA but
>> none of them have moved forward very much from what I can tell. The goal of
>> this session would be to come out with an agreement on what are the biggest
>> problems with CMA and the best ways to solve them.
>>
>
> I think this is a good topic. Some of the issues have been brought up before
> at LSF/MM but they never made that much traction so it's worth revisiting. I
> haven't been paying close attention to the mailing list discussions but
> I've been a little worried that the page allocator paths are turning into
> a bigger and bigger mess. I'm also a bit worried that options such as
> migrating pages out of CMA areas that are about to be pinned for having
> callback options to forcibly free pages never went anywhere.
>


I have two question.

First, is GCMA able to replace CMA? It's news to me.
I need some time to check GCMA.

Second, is CMA popular enough to change allocator path?
Yes, I need it.
But I don't know any company uses it, and nobody seems to have interest in it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
