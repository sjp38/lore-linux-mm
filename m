Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC8C280245
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 20:20:34 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so14582493pdb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:20:33 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id dm6si4376312pdb.96.2015.07.14.17.20.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 17:20:33 -0700 (PDT)
Received: by pacan13 with SMTP id an13so13625094pac.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:20:32 -0700 (PDT)
Date: Wed, 15 Jul 2015 09:21:06 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 0/3] zsmalloc: small compaction improvements
Message-ID: <20150715002106.GA742@swordfish>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150713233602.GA31822@blaptop.AC68U>
 <20150714003132.GA2463@swordfish>
 <20150714005459.GA12786@blaptop.AC68U>
 <20150714122932.GA597@swordfish>
 <20150714165224.GA384@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150714165224.GA384@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (07/15/15 01:52), Minchan Kim wrote:
> > alrighty... again...
> > 
> > > > 
> > > > /sys/block/zram<id>/compact is a black box. We provide it, we don't
> > > > throttle it in the kernel, and user space is absolutely clueless when
> > > > it invokes compaction. From some remote (or alternative) point of
> > > 
> > > But we have zs_can_compact so it can effectively skip the class if it
> > > is not proper class.
> > 
> > user triggered compaction can compact too much.
> > in its current state triggering a compaction from user space is like
> > playing a lottery or a russian roulette.
> 
> We were on different page.

> I thought the motivation from this patchset is to prevent compaction
> overhead by frequent user-driven compaction request because user
> don't know how they can get free pages by compaction so they should
> ask compact frequently with blind.

this is exactly the motivation for this patchset. seriously.

whatever.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
