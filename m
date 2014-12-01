Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7488D6B0069
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 19:26:46 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so9919450pab.33
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 16:26:46 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id g6si26322697pdl.217.2014.11.30.16.26.43
        for <linux-mm@kvack.org>;
        Sun, 30 Nov 2014 16:26:45 -0800 (PST)
Date: Mon, 1 Dec 2014 09:27:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [mmotm:master 210/397] mm/zsmalloc.c:1021:11: error:
 'ZS_SIZE_CLASSES' undeclared
Message-ID: <20141201002703.GB11340@bbox>
References: <201411271133.qSXTvdQZ%fengguang.wu@intel.com>
 <CADAEsF8RyCBBoxYozCOPXLkeZ0ioM2jPsqn_K-=S35CfkaKohw@mail.gmail.com>
 <CADAEsF-FBqDFp4LjeYoTC5=nPOh7qsdb6h9kOdt2sVPhFE=z9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CADAEsF-FBqDFp4LjeYoTC5=nPOh7qsdb6h9kOdt2sVPhFE=z9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hello,

On Thu, Nov 27, 2014 at 10:12:49PM +0800, Ganesh Mahendran wrote:
> Hello:
> 
> I know why the build failed.
> 
> I sent patch 1 [mm/zsmalloc: avoid duplicate assignment of prev_class]
> firstly.  It was accept.
> And then I sent patch 2 [mm/zsmalloc: support allocating obj with size
> of ZS_MAX_ALLOC_SIZE]. I was accept.
> 
> But Dan Streetman <ddstreet@ieee.org> found an issue in patch 1
> [mm/zsmalloc: avoid duplicate assignment of prev_class].
> Then the first patch 1 was dropped. But the second patch was *based*
> on the first patch. So the build is failed on:
> commit: 304e521b912aa95514a5b66f7d6795d096f15535 [210/397]
> mm/zsmalloc: support allocating obj with size of ZS_MAX_ALLOC_SIZE
> which was based on patch 1.
> 
> But it is ok after the patch [mm/zsmalloc: avoid duplicate assignment
> of prev_class].
> 
> So what should I do now?

Normally, Andrew Morton is one of kind maintainers who fixes such
trivial problem by themselves but it doesn't mean we should wait
on him so what we can do is just make a fix and describe the problem
and send it to him. Other than that, he will handle.

Thanks.

- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
