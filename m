Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 791F76B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 22:54:43 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id yy13so3468324pab.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:54:43 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id bp6si55506976pac.135.2016.02.16.19.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 19:54:42 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id q63so3589001pfb.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:54:42 -0800 (PST)
Date: Wed, 17 Feb 2016 12:55:58 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: drop unused member 'mapping_area->huge'
Message-ID: <20160217035558.GA15278@swordfish>
References: <1455674199-6227-1-git-send-email-xuyiping@huawei.com>
 <20160217022552.GB535@swordfish>
 <56C3E91B.1030101@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56C3E91B.1030101@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xuyiping <xuyiping@hisilicon.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, YiPing Xu <xuyiping@huawei.com>, minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, suzhuangluan@hisilicon.com, puck.chen@hisilicon.com, dan.zhao@hisilicon.com

On (02/17/16 11:29), xuyiping wrote:
[..]
> 
> 	if (off + class->size <= PAGE_SIZE) {
> 
> for huge object, the code will get into this branch, there is no more huge
> object process in __zs_map_object.

correct, well, techically, it's not about huge objects, but objects that span
page boundaries. we can have objects of pretty small sizes being split between
pages, for example size:1536 and offset:3072, etc.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
