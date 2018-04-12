Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A70BF6B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 17:15:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b16so3591336pfi.5
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 14:15:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 3-v6si3985860plr.440.2018.04.12.14.15.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 14:15:45 -0700 (PDT)
Date: Thu, 12 Apr 2018 14:15:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] radix tree test suite: fix mapshift build target
Message-Id: <20180412141543.a9d587c3836338e78de33d30@linux-foundation.org>
In-Reply-To: <20180412210518.27557-1-ross.zwisler@linux.intel.com>
References: <20180412210518.27557-1-ross.zwisler@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Thu, 12 Apr 2018 15:05:18 -0600 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:

> The following commit
> 
>   commit c6ce3e2fe3da ("radix tree test suite: Add config option for map
>   shift")
> 
> Introduced a phony makefile target called 'mapshift' that ends up
> generating the file generated/map-shift.h.  This phony target was then
> added as a dependency of the top level 'targets' build target, which is
> what is run when you go to tools/testing/radix-tree and just type 'make'.
> 
> Unfortunately, this phony target doesn't actually work as a dependency, so
> you end up getting:
> 
> $ make
> make: *** No rule to make target 'generated/map-shift.h', needed by 'main.o'.  Stop.
> make: *** Waiting for unfinished jobs....
> 
> Fix this by making the file generated/map-shift.h our real makefile target,
> and add this a dependency of the top level build target.

I still get

akpm3:/usr/src/25/tools/testing/radix-tree> make
cc -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address   -c -o main.o main.c
In file included from ./linux/../../../../include/linux/radix-tree.h:28:0,
                 from ./linux/radix-tree.h:6,
                 from main.c:10:
./linux/rcupdate.h:5:10: fatal error: urcu.h: No such file or directory
 #include <urcu.h>


lots of breakage here :(
