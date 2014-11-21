Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 72F036B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 16:21:08 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id hl2so2261827igb.4
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 13:21:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ii1si395433igb.19.2014.11.21.13.21.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Nov 2014 13:21:07 -0800 (PST)
Date: Fri, 21 Nov 2014 13:21:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [balancenuma:mm-numa-protnone-v3r3 83/362]
 include/linux/compaction.h:108:1: error: expected identifier or '(' before
 '{' token
Message-Id: <20141121132105.f48085180ac3756028d0a846@linux-foundation.org>
In-Reply-To: <201411220114.QnSQfMwJ%fengguang.wu@intel.com>
References: <201411220114.QnSQfMwJ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 22 Nov 2014 01:20:17 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma mm-numa-protnone-v3r3
> head:   e5d6f2e502e06020eeb0f852a5ed853802799eb3
> commit: 17d9af0e32bdc4f263e23daefea699ed463bb87c [83/362] mm, compaction: simplify deferred compaction
> config: x86_64-allnoconfig (attached as .config)
> reproduce:
>   git checkout 17d9af0e32bdc4f263e23daefea699ed463bb87c
>   # save the attached .config to linux build tree
>   make ARCH=x86_64 
> 
> Note: the balancenuma/mm-numa-protnone-v3r3 HEAD e5d6f2e502e06020eeb0f852a5ed853802799eb3 builds fine.
>       It only hurts bisectibility.
> 
> All error/warnings:
> 
>    In file included from kernel/sysctl.c:43:0:
> >> include/linux/compaction.h:108:1: error: expected identifier or '(' before '{' token
>     {

That's fixed in the next patch,
mm-compaction-simplify-deferred-compaction-fix.patch.

Your bisectbot broke again :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
