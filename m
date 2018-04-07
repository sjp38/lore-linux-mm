Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94A6F6B0003
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 00:19:36 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id w16so2308182uad.0
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 21:19:36 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b25sor4516357uam.238.2018.04.06.21.19.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Apr 2018 21:19:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180406205828.GA9618@bombadil.infradead.org>
References: <CADYJ94f8ObREJu7pW9zWqtTCuiT2TygjWA7n1Uv-8YC7aehDAw@mail.gmail.com>
 <20180406205828.GA9618@bombadil.infradead.org>
From: Chandan Vn <vn.chandan@gmail.com>
Date: Sat, 7 Apr 2018 09:48:54 +0530
Message-ID: <CADYJ94c7YKG3txKMpufVUhSjV8r0WpB6NFiOWUutex+oQ-fwNA@mail.gmail.com>
Subject: Re: Requesting to share current work items
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

On Sat, Apr 7, 2018 at 2:28 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, Apr 06, 2018 at 07:20:47AM +0000, Chandan Vn wrote:
>> Hi,
>>
>> I would like to start contributing to linux-mm community.
>> Could you please let me know the current work items which I can start
>> working on.
>>
>> Please note that I have been working on linux-mm from past 4 years but
>> mostly proprietary or not yet mainlined vendor codebase.
>
> We had a report of a problem a few weeks ago that I don't know if anybody
> is looking at yet.  Perhaps you'd like to try fixing it.
>
> The report says that, under some unidentified workload, calling vmalloc
> can take many hundreds of milliseconds, and the problem is in
> alloc_vmap_area().
>
> So a good plan of work would be to devise a kernel module which can
> produce a highly-fragmented vmap area, and demonstrate the problem.
> Once you've got a reliable reproducer, you can look at how to fix this
> problem.  We probably need a better data structure; either enhance
> the existing rbtree of free areas, or change the data structure.

Sure. I would work on this.
