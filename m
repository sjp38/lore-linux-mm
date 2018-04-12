Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 680936B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 17:19:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 2so3594888pft.4
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 14:19:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f91-v6si4284924plb.178.2018.04.12.14.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Apr 2018 14:19:44 -0700 (PDT)
Date: Thu, 12 Apr 2018 14:19:41 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] radix tree test suite: fix mapshift build target
Message-ID: <20180412211941.GC18364@bombadil.infradead.org>
References: <20180412210518.27557-1-ross.zwisler@linux.intel.com>
 <20180412141543.a9d587c3836338e78de33d30@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180412141543.a9d587c3836338e78de33d30@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Thu, Apr 12, 2018 at 02:15:43PM -0700, Andrew Morton wrote:
> On Thu, 12 Apr 2018 15:05:18 -0600 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:
> 
> > The following commit
> > 
> >   commit c6ce3e2fe3da ("radix tree test suite: Add config option for map
> >   shift")
> > 
> > Introduced a phony makefile target called 'mapshift' that ends up
> > generating the file generated/map-shift.h.  This phony target was then
> > added as a dependency of the top level 'targets' build target, which is
> > what is run when you go to tools/testing/radix-tree and just type 'make'.
> > 
> > Unfortunately, this phony target doesn't actually work as a dependency, so
> > you end up getting:
> > 
> > $ make
> > make: *** No rule to make target 'generated/map-shift.h', needed by 'main.o'.  Stop.
> > make: *** Waiting for unfinished jobs....
> > 
> > Fix this by making the file generated/map-shift.h our real makefile target,
> > and add this a dependency of the top level build target.
> 
> I still get
> 
> akpm3:/usr/src/25/tools/testing/radix-tree> make
> cc -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address   -c -o main.o main.c
> In file included from ./linux/../../../../include/linux/radix-tree.h:28:0,
>                  from ./linux/radix-tree.h:6,
>                  from main.c:10:
> ./linux/rcupdate.h:5:10: fatal error: urcu.h: No such file or directory

apt-get install liburcu-dev

>  #include <urcu.h>
> 
> 
> lots of breakage here :(
> 
