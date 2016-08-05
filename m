Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D88106B0005
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 20:43:54 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so433694161pab.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 17:43:54 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id m63si17234251pfb.137.2016.08.04.17.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 17:43:54 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id y134so91462309pfg.0
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 17:43:53 -0700 (PDT)
Date: Fri, 5 Aug 2016 09:43:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: Choosing z3fold allocator in zswap gives WARNING: CPU: 0 PID:
 5140 at mm/zswap.c:503 __zswap_pool_current+0x56/0x60
Message-ID: <20160805004357.GA514@swordfish>
References: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl>
 <20160804115809.GA447@swordfish>
 <CALZtONBODigWHuCdz0j9OUTwEhs9vdfuQZ1HnjHDLXNdNdz4qg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALZtONBODigWHuCdz0j9OUTwEhs9vdfuQZ1HnjHDLXNdNdz4qg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, Vitaly Wool <vitalywool@gmail.com>, Marcin =?utf-8?B?TWlyb3PFgmF3?= <marcin@mejor.pl>, Andrew Morton <akpm@linux-foundation.org>

On (08/04/16 14:15), Dan Streetman wrote:
[..]
>    yep that's exactly right.  I reproduced it with zbud compiled out.
[..]
>    yep that's true as well.
>    i can get patches going for both these, unless you're already working on
>    it?

please go ahead.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
