Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BD7A86B0093
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 19:46:50 -0500 (EST)
Received: by pwj7 with SMTP id 7so3735535pwj.14
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 16:46:49 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 24 Feb 2010 01:46:49 +0100
Message-ID: <17cb70ee1002231646m508f6483mcb667d4e67d9807f@mail.gmail.com>
Subject: way to allocate memory within a range ?
From: Auguste Mome <augustmome@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
I'd like to use kmem_cache() system, but need the memory taken from a
specific range if requested, outside the range otherwise.
I think about adding new zone and define new GFP flag to either select or
ignore the zone. Does it sound possible? Then I welcome any hint if you know
where to add the appropriated test in allocator, how to attach the
region to the new zone id).

Or slab/slub system is not designed for this, I should forget it and
opt for another system?

August.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
