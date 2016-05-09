Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D05726B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 01:01:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so358724077pfy.2
        for <linux-mm@kvack.org>; Sun, 08 May 2016 22:01:11 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id n76si35318094pfa.84.2016.05.08.22.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 May 2016 22:01:11 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id y69so70939961pfb.1
        for <linux-mm@kvack.org>; Sun, 08 May 2016 22:01:10 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Date: Mon, 9 May 2016 14:01:02 +0900
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration in
 get_pages_per_zspage()
Message-ID: <20160509050102.GA4574@blaptop>
References: <1462425447-13385-1-git-send-email-opensource.ganesh@gmail.com>
 <20160505100329.GA497@swordfish>
 <20160506030935.GA18573@bbox>
 <CADAEsF9S4GQE6V+zsvRRVYjdbfN3VRQFcTiN5E_MWw60bfk0Zw@mail.gmail.com>
 <20160506090801.GA488@swordfish>
 <20160506093342.GB488@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160506093342.GB488@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, May 06, 2016 at 06:33:42PM +0900, Sergey Senozhatsky wrote:
> On (05/06/16 18:08), Sergey Senozhatsky wrote:
> [..]
> > and it's not 45 iterations that we are getting rid of, but around 31:
> > not every class reaches it's ideal 100% ratio on the first iteration.
> > so, no, sorry, I don't think the patch really does what we want.
> 
> 
> to be clear, what I meant was:
> 
>   495 `cmp' + 15 `cmp je'                         IN
>   31 `mov cltd idiv mov sub imul cltd idiv cmp'   OUT
> 
> IN > OUT.
> 
> 
> CORRECTION here:
> 
> > * by the way, we don't even need `cltd' in those calculations. the
> > reason why gcc puts cltd is because ZS_MAX_PAGES_PER_ZSPAGE has the
> > 'wrong' data type. the patch to correct it is below (not a formal
> > patch).
> 
> no, we need cltd there. but ZS_MAX_PAGES_PER_ZSPAGE also affects
> ZS_MIN_ALLOC_SIZE, which is used in several places, like
> get_size_class_index(). that's why ZS_MAX_PAGES_PER_ZSPAGE data
> type change `improves' zs_malloc().

Why not if such simple improves zsmalloc? :)
Please send a patch.

Thanks a lot, Sergey!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
