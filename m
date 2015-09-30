Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 590D46B0255
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 04:02:01 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so184114358wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:02:01 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id eu7si19706581wic.44.2015.09.30.01.02.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 01:02:00 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so184113597wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:01:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150930075203.GC12727@bbox>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
	<20150915061349.GA16485@bbox>
	<CAMJBoFM_bMvQthAJPK+w4uQznqp7eFLdk=c7ZtT-R1aoF-1SeA@mail.gmail.com>
	<20150930075203.GC12727@bbox>
Date: Wed, 30 Sep 2015 10:01:59 +0200
Message-ID: <CAMJBoFN3j5eZh4+4dnJya9=8Jo=3O9u+v7g0Ka+aVaQyMOG2ew@mail.gmail.com>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, =?UTF-8?B?6rmA7KSA7IiY?= <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

> Could you share your script?
> I will ask our production team to reproduce it.

Wait, let me get it right. Your production team?
I take it as you would like me to help your company fix your bugs.
You are pushing the limits here.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
