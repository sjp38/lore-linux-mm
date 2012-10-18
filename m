Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id ACCBB6B0062
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 18:41:51 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so18140769ied.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 15:41:51 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 18 Oct 2012 19:41:51 -0300
Message-ID: <CALF0-+XKorADZ7DSp_yDFG4UkYr3W_pXHCA0ZWVzZpd8dJW_Gw@mail.gmail.com>
Subject: [PATCH 0/3] Small slob fixes and some more comon code
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Tim Bird <tim.bird@am.sony.com>

Hi folks,

A little patchset brought to you by the CELF project:
"Kernel dynamic memory allocation tracking and reduction" [1].

This applies cleanly on top of Pekka's slab/for-linus,
which seems to be the latest branch.
(slab-next is a bit outdated)

Ezequiel Garcia (3):
 mm/sl[aou]b: Move common kmem_cache_size() to slab.h
 mm/slob: Use object_size field in kmem_cache_size()
 mm/slob: Drop usage of page->private for storing page-sized allocations

 include/linux/slab.h |    9 ++++++++-
 mm/slab.c            |    6 ------
 mm/slob.c            |   34 ++++++++++++----------------------
 mm/slub.c            |    9 ---------
 4 files changed, 20 insertions(+), 38 deletions(-)

 Any comments/flames welcome!
Thanks!

    Ezequiel

[1] http://elinux.org/Kernel_dynamic_memory_allocation_tracking_and_reduction

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
