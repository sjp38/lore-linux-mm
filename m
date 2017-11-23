Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7AF6B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 00:51:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m4so5511359pgc.23
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 21:51:55 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id t2si14860042pgb.591.2017.11.22.21.51.53
        for <linux-mm@kvack.org>;
        Wed, 22 Nov 2017 21:51:54 -0800 (PST)
Date: Thu, 23 Nov 2017 14:57:33 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
Message-ID: <20171123055732.GA31720@js1304-P5Q-DELUXE>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE>
 <da3f79bc-ef84-d516-b659-1f213d46a79f@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <da3f79bc-ef84-d516-b659-1f213d46a79f@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Wengang Wang <wen.gang.wang@oracle.com>, Linux-MM <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>

On Wed, Nov 22, 2017 at 03:04:51PM +0300, Andrey Ryabinin wrote:
> On 11/20/2017 04:50 AM, Joonsoo Kim wrote:
> > 
> > The reason I didn't submit the vchecker to mainline is that I didn't find
> > the case that this tool is useful in real life. Most of the system broken case
> > can be debugged by other ways. Do you see the real case that this tool is
> > helpful? If so, I think that vchecker is more appropriate to be upstreamed.
> > Could you share your opinion?
> > 
> 
> Isn't everything that vchecker can do and far beyond that can be done via systemtap
> script using watchpoints?

I don't have enough knowledge about systemtap however I guess that
it's not possible. vchecker uses the ASAN hooks which are placed on
all memory read/write around the kernel. We cannot easily add
watchpoints for them.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
