Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 733B96B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 06:32:35 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so8831610wiv.0
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 03:32:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dh10si15853923wib.80.2014.11.25.03.32.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 03:32:34 -0800 (PST)
Date: Tue, 25 Nov 2014 11:32:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Improving CMA
Message-ID: <20141125113225.GH2725@suse.de>
References: <5473E146.7000503@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5473E146.7000503@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>, minchan@kernel.org, zhuhui@xiaomi.com, iamjoonsoo.kim@lge.com, gioh.kim@lge.com

On Mon, Nov 24, 2014 at 05:54:14PM -0800, Laura Abbott wrote:
> There have been a number of patch series posted designed to improve various
> aspects of CMA. A sampling:
> 
> https://lkml.org/lkml/2014/10/15/623
> http://marc.info/?l=linux-mm&m=141571797202006&w=2
> https://lkml.org/lkml/2014/6/26/549
> 
> As far as I can tell, these are all trying to fix real problems with CMA but
> none of them have moved forward very much from what I can tell. The goal of
> this session would be to come out with an agreement on what are the biggest
> problems with CMA and the best ways to solve them.
> 

I think this is a good topic. Some of the issues have been brought up before
at LSF/MM but they never made that much traction so it's worth revisiting. I
haven't been paying close attention to the mailing list discussions but
I've been a little worried that the page allocator paths are turning into
a bigger and bigger mess. I'm also a bit worried that options such as
migrating pages out of CMA areas that are about to be pinned for having
callback options to forcibly free pages never went anywhere.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
