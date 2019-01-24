Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80A498E0079
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 06:57:06 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id p65-v6so1612280ljb.16
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 03:57:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor1881192lfj.30.2019.01.24.03.57.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 03:57:04 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [PATCH v1 0/2] stability fixes for vmalloc allocator
Date: Thu, 24 Jan 2019 12:56:46 +0100
Message-Id: <20190124115648.9433-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

Hello.

The vmalloc test driver(https://lkml.org/lkml/2019/1/2/52) has been
added to the linux-next. Therefore i would like to fix some stability
issues i identified using it. I explained those issues in detail here:

https://lkml.org/lkml/2018/10/19/786

There are two patches, i think they are pretty ready to go with, unless
there are any comments from you.

Thank you!

--
Vlad Rezki

Uladzislau Rezki (Sony) (2):
  mm/vmalloc: fix kernel BUG at mm/vmalloc.c:512!
  mm: add priority threshold to __purge_vmap_area_lazy()

 mm/vmalloc.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

-- 
2.11.0
