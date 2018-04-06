Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC17E6B002B
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 16:58:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k17so1302396pfj.10
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 13:58:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y7si7497692pgp.727.2018.04.06.13.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Apr 2018 13:58:29 -0700 (PDT)
Date: Fri, 6 Apr 2018 13:58:28 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Requesting to share current work items
Message-ID: <20180406205828.GA9618@bombadil.infradead.org>
References: <CADYJ94f8ObREJu7pW9zWqtTCuiT2TygjWA7n1Uv-8YC7aehDAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADYJ94f8ObREJu7pW9zWqtTCuiT2TygjWA7n1Uv-8YC7aehDAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chandan Vn <vn.chandan@gmail.com>
Cc: linux-mm@kvack.org

On Fri, Apr 06, 2018 at 07:20:47AM +0000, Chandan Vn wrote:
> Hi,
> 
> I would like to start contributing to linux-mm community.
> Could you please let me know the current work items which I can start
> working on.
> 
> Please note that I have been working on linux-mm from past 4 years but
> mostly proprietary or not yet mainlined vendor codebase.

We had a report of a problem a few weeks ago that I don't know if anybody
is looking at yet.  Perhaps you'd like to try fixing it.

The report says that, under some unidentified workload, calling vmalloc
can take many hundreds of milliseconds, and the problem is in
alloc_vmap_area().

So a good plan of work would be to devise a kernel module which can
produce a highly-fragmented vmap area, and demonstrate the problem.
Once you've got a reliable reproducer, you can look at how to fix this
problem.  We probably need a better data structure; either enhance
the existing rbtree of free areas, or change the data structure.
