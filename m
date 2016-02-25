Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B94AE6B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 10:13:02 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id g62so33271592wme.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 07:13:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 193si4564789wmp.94.2016.02.25.07.13.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Feb 2016 07:13:01 -0800 (PST)
Date: Thu, 25 Feb 2016 16:12:56 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
In-Reply-To: <56CF1202.2020809@emindsoft.com.cn>
Message-ID: <alpine.LNX.2.00.1602251609120.22700@cbobk.fhfr.pm>
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Mel Gorman <mgorman@techsingularity.net>, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Thu, 25 Feb 2016, Chen Gang wrote:

> I can understand for your NAK, it is a trivial patch. 

Not all trivial patches are NAKed :) But they have to be generally useful.

Shuffling code around, without actually changing / improving it a bit, 
just for the sole purpose of formatting, is kind of pointless (especially 
given the fact that the current code as-is is easily readable; it's not 
like it'd be a horrible mess difficult to understand).

Sure, it might had been formatted better at the time it was actually 
merged. But changing it "just because" after being in tree for long time 
doesn't fix any problem really.

> And excuse me, I guess my english is not quite well, I am not quite
> understand the meaning below, could you provide more details?
> 
>   "it's preferable to preserve blame than go through a layer of cleanup
>   when looking for the commit that defined particular flags".

git-blame. When looking at commits touching particular lines, you add an 
extra hop to the person who is trying to find a (functional) commit that 
touched a particular line.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
