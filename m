Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id BD3EE6B0256
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 04:11:05 -0400 (EDT)
Received: by ioii196 with SMTP id i196so38887157ioi.3
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:11:05 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id j5si240801igt.82.2015.09.30.01.11.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 01:11:05 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so34029907pac.2
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:11:05 -0700 (PDT)
Date: Wed, 30 Sep 2015 17:13:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
Message-ID: <20150930081304.GE12727@bbox>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <20150915061349.GA16485@bbox>
 <CAMJBoFM_bMvQthAJPK+w4uQznqp7eFLdk=c7ZtT-R1aoF-1SeA@mail.gmail.com>
 <20150930075203.GC12727@bbox>
 <CAMJBoFN3j5eZh4+4dnJya9=8Jo=3O9u+v7g0Ka+aVaQyMOG2ew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMJBoFN3j5eZh4+4dnJya9=8Jo=3O9u+v7g0Ka+aVaQyMOG2ew@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, =?utf-8?B?6rmA7KSA7IiY?= <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Sep 30, 2015 at 10:01:59AM +0200, Vitaly Wool wrote:
> > Could you share your script?
> > I will ask our production team to reproduce it.
> 
> Wait, let me get it right. Your production team?
> I take it as you would like me to help your company fix your bugs.
> You are pushing the limits here.

I'm really sorry if you take it as fixing my bugs.
I never wanted it but just want to help your problem.
Please read LKML. Normally, developers wanted to share test script to
reproduce the problem because it's easier to solve the problem
without consuming much time with ping-pong.

Anyway, I have shared my experience to you and suggest patches and
on-going works. In your concept, I shouldn't do that for fixing
your problems so I shouldn't help you any more? Right?

> 
> ~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
