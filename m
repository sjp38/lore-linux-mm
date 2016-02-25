Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD456B0253
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 17:16:11 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id l127so103591507iof.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:16:11 -0800 (PST)
Received: from out1134-219.mail.aliyun.com (out1134-219.mail.aliyun.com. [42.120.134.219])
        by mx.google.com with ESMTP id m16si268875igt.54.2016.02.25.14.16.10
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 14:16:10 -0800 (PST)
Message-ID: <56CF7E00.10101@emindsoft.com.cn>
Date: Fri, 26 Feb 2016 06:19:44 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <alpine.LNX.2.00.1602251609120.22700@cbobk.fhfr.pm>
In-Reply-To: <alpine.LNX.2.00.1602251609120.22700@cbobk.fhfr.pm>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <gang.chen.5i5j@gmail.com>


On 2/25/16 23:12, Jiri Kosina wrote:
> On Thu, 25 Feb 2016, Chen Gang wrote:
> 
>> I can understand for your NAK, it is a trivial patch. 
> 
> Not all trivial patches are NAKed :) But they have to be generally useful.
> 
> Shuffling code around, without actually changing / improving it a bit, 
> just for the sole purpose of formatting, is kind of pointless (especially 
> given the fact that the current code as-is is easily readable; it's not 
> like it'd be a horrible mess difficult to understand).
> 
> Sure, it might had been formatted better at the time it was actually 
> merged. But changing it "just because" after being in tree for long time 
> doesn't fix any problem really.
> 

OK, thanks. I have replied the related contents in the other thread.

Welcome any ideas, suggestions, and completions in the other related
thread.

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
