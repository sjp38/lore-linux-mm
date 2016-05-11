Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 818286B007E
	for <linux-mm@kvack.org>; Wed, 11 May 2016 05:33:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 4so74743952pfw.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 02:33:04 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id g28si8425236pfg.142.2016.05.11.02.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 02:33:03 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id r187so3984330pfr.2
        for <linux-mm@kvack.org>; Wed, 11 May 2016 02:33:03 -0700 (PDT)
Date: Wed, 11 May 2016 18:34:35 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration in
 get_pages_per_zspage()
Message-ID: <20160511093435.GA13113@swordfish>
References: <1462425447-13385-1-git-send-email-opensource.ganesh@gmail.com>
 <20160505100329.GA497@swordfish>
 <20160506030935.GA18573@bbox>
 <CADAEsF9S4GQE6V+zsvRRVYjdbfN3VRQFcTiN5E_MWw60bfk0Zw@mail.gmail.com>
 <20160506090801.GA488@swordfish>
 <20160506093342.GB488@swordfish>
 <20160509050102.GA4574@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160509050102.GA4574@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On (05/09/16 14:01), Minchan Kim wrote:
[..]
> > no, we need cltd there. but ZS_MAX_PAGES_PER_ZSPAGE also affects
> > ZS_MIN_ALLOC_SIZE, which is used in several places, like
> > get_size_class_index(). that's why ZS_MAX_PAGES_PER_ZSPAGE data
> > type change `improves' zs_malloc().
> 
> Why not if such simple improves zsmalloc? :)
> Please send a patch.
> 
> Thanks a lot, Sergey!

Hello Minchan,

sorry for long reply, I decided to investigate it a bit further.
with this patch, gcc 6.1 -O2 generates "+13" instructions more,
-Os "-25" instructions less. this +13 ins case is a no-no-no.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
